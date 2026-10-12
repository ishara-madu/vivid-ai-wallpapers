/**
 * VIVID NOTCH AI • WALLPAPER STUDIO & UPLOADER
 * Pure Vanilla JavaScript Client-Side Engine
 * --------------------------------------------------------------------------
 * Directly interfaces with GitHub REST API to upload wallpapers, generate WebP
 * thumbnails in-browser, extract dominant colors, and manage catalog.json.
 */

(() => {
  'use strict';

  // --- Configuration & State ---
  const STORAGE_KEYS = {
    TOKEN: 'vivid_github_token',
    REPO: 'vivid_github_repo',
    BRANCH: 'vivid_github_branch'
  };

  const DEFAULT_REPO = 'ishara-madu/vivid-ai-wallpapers';
  const DEFAULT_BRANCH = 'main';

  const CATEGORY_MAP = {
    'Creative Cutouts': { folder: 'categories/creative_cutouts' },
    'AMOLED & Stealth': { folder: 'categories/amoled_stealth' },
    'Cyberpunk & Sci-Fi': { folder: 'categories/cyberpunk' },
    'Abstract & 3D': { folder: 'categories/abstract' },
    'Minimal & Vector': { folder: 'categories/minimal' },
    'Nature & Landscapes': { folder: 'categories/landscapes' },
    'Anime & Gaming': { folder: 'categories/anime' },
    'Vibrant Flows': { folder: 'categories/vibrant_flows' }
  };

  let state = {
    token: localStorage.getItem(STORAGE_KEYS.TOKEN) || '',
    repo: localStorage.getItem(STORAGE_KEYS.REPO) || DEFAULT_REPO,
    branch: localStorage.getItem(STORAGE_KEYS.BRANCH) || DEFAULT_BRANCH,
    currentFile: null,
    fileDataUrl: null,
    imageDims: { width: 1080, height: 2400 },
    thumbBlob: null,
    thumbBase64: null,
    primaryColor: '#0F172A',
    secondaryColor: '#38BDF8',
    catalog: [],
    selectedIds: new Set(),
    activeFilter: 'All',
    searchQuery: ''
  };

  // --- DOM Elements ---
  const elements = {
    // Navigation & Tabs
    tabs: document.querySelectorAll('.tab-btn'),
    sections: document.querySelectorAll('.view-section'),
    statusPill: document.getElementById('btn-status-pill'),
    statusDot: document.getElementById('status-indicator-dot'),
    statusText: document.getElementById('status-text'),
    catalogBadge: document.getElementById('catalog-count-badge'),

    // Uploader View
    dropzone: document.getElementById('dropzone'),
    fileInput: document.getElementById('file-input'),
    fileLoadedBar: document.getElementById('file-loaded-bar'),
    fileTitleDisplay: document.getElementById('file-title-display'),
    fileDimsDisplay: document.getElementById('file-dimensions-display'),
    btnRemoveFile: document.getElementById('btn-remove-file'),
    
    // Metadata Form
    form: document.getElementById('form-wallpaper'),
    inputTitle: document.getElementById('input-title'),
    selectCategory: document.getElementById('select-category'),
    selectCutoutType: document.getElementById('select-cutout-type'),
    inputResolution: document.getElementById('input-resolution'),
    inputDimensions: document.getElementById('input-dimensions'),
    inputDescription: document.getElementById('input-description'),
    colorGradBar: document.getElementById('gradient-preview-bar'),
    colorInputPrimary: document.getElementById('input-color-primary'),
    colorInputSecondary: document.getElementById('input-color-secondary'),
    colorHexPrimary: document.getElementById('color-hex-primary'),
    colorHexSecondary: document.getElementById('color-hex-secondary'),
    btnPublish: document.getElementById('btn-publish'),
    btnReset: document.getElementById('btn-reset'),

    // Phone Simulator & Inspector
    wallpaperPreview: document.getElementById('phone-wallpaper-preview'),
    placeholderState: document.getElementById('phone-empty-state'),
    cutoutTabs: document.querySelectorAll('.cutout-tab-pill'),
    overlayCenter: document.getElementById('overlay-center-hole'),
    overlayIsland: document.getElementById('overlay-dynamic-island'),
    overlayLeft: document.getElementById('overlay-left-hole'),
    statThumbSize: document.getElementById('stat-thumb-size'),
    statNotchName: document.getElementById('stat-notch-name'),

    // Catalog View & Batch Controls
    catalogGrid: document.getElementById('catalog-grid'),
    catalogEmpty: document.getElementById('catalog-empty-state'),
    catalogSearch: document.getElementById('catalog-search-input'),
    catalogFilterPills: document.querySelectorAll('.cat-pill'),
    batchBar: document.getElementById('batch-action-bar'),
    batchCountText: document.getElementById('batch-count-text'),
    btnDeleteSelected: document.getElementById('btn-delete-selected'),
    btnClearSelection: document.getElementById('btn-clear-selection'),
    btnToggleSelectAll: document.getElementById('btn-toggle-select-all'),
    btnToolbarSelectAll: document.getElementById('btn-toolbar-select-all'),

    // Settings View
    inputRepoOwner: document.getElementById('input-repo-owner'),
    inputRepoBranch: document.getElementById('input-repo-branch'),
    inputGithubToken: document.getElementById('input-github-token'),
    btnSaveSettings: document.getElementById('btn-save-settings'),
    btnToggleMask: document.getElementById('btn-toggle-token-mask'),

    // Publish Modal
    modalPublish: document.getElementById('modal-publish'),
    modalTitle: document.getElementById('modal-title'),
    modalDesc: document.getElementById('modal-desc'),
    modalIcon: document.getElementById('modal-icon-wrap'),
    modalActions: document.getElementById('modal-success-actions'),
    btnModalDone: document.getElementById('btn-modal-done'),
    linkCommitView: document.getElementById('link-commit-view'),
    steps: {
      step1: document.getElementById('step-1'),
      step2: document.getElementById('step-2'),
      step3: document.getElementById('step-3'),
      step4: document.getElementById('step-4')
    },

    // Hidden Canvas Engine & Toast
    canvas: document.getElementById('canvas-engine'),
    toastContainer: document.getElementById('toast-container')
  };

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================
  function init() {
    setupTabNavigation();
    setupDropzone();
    setupColorInputs();
    setupFormEvents();
    setupSimulatorEvents();
    setupSettingsEvents();
    setupCatalogEvents();

    // Populate Settings UI
    elements.inputRepoOwner.value = state.repo;
    elements.inputRepoBranch.value = state.branch;
    if (state.token) {
      elements.inputGithubToken.value = state.token;
      testGithubConnection();
    } else {
      updateStatusBadge('unconfigured', 'Token Required');
    }

    // Preload live catalog in background
    loadLiveCatalog();
  }

  // ==========================================================================
  // TAB NAVIGATION
  // ==========================================================================
  function setupTabNavigation() {
    elements.tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const targetId = tab.dataset.target;
        elements.tabs.forEach(t => t.classList.remove('active'));
        elements.sections.forEach(s => s.classList.remove('active'));

        tab.classList.add('active');
        const targetSection = document.getElementById(targetId);
        if (targetSection) targetSection.classList.add('active');

        if (targetId === 'view-catalog') {
          loadLiveCatalog();
        }
      });
    });

    elements.statusPill.addEventListener('click', () => {
      // Switch directly to Settings tab
      const settingsTab = document.getElementById('tab-settings');
      if (settingsTab) settingsTab.click();
    });
  }

  // ==========================================================================
  // TOAST NOTIFICATIONS
  // ==========================================================================
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;

    let iconSvg = '';
    if (type === 'success') {
      iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>';
    } else if (type === 'error') {
      iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>';
    } else {
      iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>';
    }

    toast.innerHTML = `${iconSvg}<span>${escapeHtml(message)}</span>`;
    elements.toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 4000);
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.innerText = text;
    return div.innerHTML;
  }

  // ==========================================================================
  // FILE HANDLING & IMAGE PROCESSING
  // ==========================================================================
  function setupDropzone() {
    const dropzone = elements.dropzone;
    const fileInput = elements.fileInput;

    ['dragenter', 'dragover'].forEach(name => {
      dropzone.addEventListener(name, e => {
        e.preventDefault();
        dropzone.classList.add('dragover');
      });
    });

    ['dragleave', 'drop'].forEach(name => {
      dropzone.addEventListener(name, e => {
        e.preventDefault();
        dropzone.classList.remove('dragover');
      });
    });

    dropzone.addEventListener('drop', e => {
      if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0]) {
        processSelectedFile(e.dataTransfer.files[0]);
      }
    });

    fileInput.addEventListener('change', e => {
      if (fileInput.files && fileInput.files[0]) {
        processSelectedFile(fileInput.files[0]);
      }
    });

    elements.btnRemoveFile.addEventListener('click', () => {
      resetFileSelection();
    });
  }

  function processSelectedFile(file) {
    if (!file.type.startsWith('image/')) {
      showToast('Please select a valid image file (PNG, JPG, or WebP)', 'error');
      return;
    }

    state.currentFile = file;

    const reader = new FileReader();
    reader.onload = e => {
      state.fileDataUrl = e.target.result;

      // Load into an HTML Image object to inspect dimensions and extract colors
      const img = new Image();
      img.onload = () => {
        state.imageDims = { width: img.naturalWidth, height: img.naturalHeight };

        // Update UI
        elements.fileTitleDisplay.textContent = file.name;
        elements.fileDimsDisplay.textContent = `${state.imageDims.width} × ${state.imageDims.height} px • ${(file.size / (1024 * 1024)).toFixed(2)} MB`;
        elements.fileLoadedBar.classList.add('active');
        elements.dropzone.style.display = 'none';

        // Auto-fill Title if empty
        if (!elements.inputTitle.value.trim()) {
          const cleanName = file.name
            .replace(/\.[^/.]+$/, '')
            .replace(/[_-]+/g, ' ')
            .replace(/\b\w/g, c => c.toUpperCase());
          elements.inputTitle.value = cleanName;
        }

        // Auto-calculate resolution classification
        elements.inputDimensions.value = `${state.imageDims.width} x ${state.imageDims.height}`;
        if (state.imageDims.height >= 3000 || state.imageDims.width >= 1800) {
          elements.inputResolution.value = '4K Ultra HD';
        } else if (state.imageDims.height >= 2400) {
          elements.inputResolution.value = 'QHD+ AMOLED';
        } else {
          elements.inputResolution.value = 'Full HD+';
        }

        // Show image inside phone simulator
        elements.wallpaperPreview.src = state.fileDataUrl;
        elements.wallpaperPreview.style.display = 'block';
        elements.placeholderState.style.display = 'none';

        // Extract Dominant Colors and WebP Thumbnail
        extractColorsFromImage(img);
        generateWebPThumbnail(img);

        // Enable publish button
        elements.btnPublish.disabled = false;
        showToast('Wallpaper loaded and analyzed successfully!', 'success');
      };
      img.src = state.fileDataUrl;
    };
    reader.readAsDataURL(file);
  }

  function resetFileSelection() {
    state.currentFile = null;
    state.fileDataUrl = null;
    state.thumbBlob = null;
    state.thumbBase64 = null;
    elements.fileInput.value = '';
    elements.fileLoadedBar.classList.remove('active');
    elements.dropzone.style.display = 'block';
    elements.wallpaperPreview.style.display = 'none';
    elements.placeholderState.style.display = 'flex';
    elements.btnPublish.disabled = true;
    elements.statThumbSize.textContent = 'Auto 360 × 640';
  }

  // ==========================================================================
  // COLOR EXTRACTION & GRADIENT PREVIEW
  // ==========================================================================
  function extractColorsFromImage(img) {
    const canvas = elements.canvas;
    const ctx = canvas.getContext('2d', { willReadFrequently: true });
    canvas.width = 16;
    canvas.height = 16;
    ctx.drawImage(img, 0, 0, 16, 16);

    const imgData = ctx.getImageData(0, 0, 16, 16).data;
    const colorCounts = {};

    for (let i = 0; i < imgData.length; i += 4) {
      const r = imgData[i];
      const g = imgData[i + 1];
      const b = imgData[i + 2];
      // Quantize slightly for clustering
      const qr = Math.round(r / 16) * 16;
      const qg = Math.round(g / 16) * 16;
      const qb = Math.round(b / 16) * 16;
      const key = `${qr},${qg},${qb}`;
      colorCounts[key] = (colorCounts[key] || 0) + 1;
    }

    const sorted = Object.entries(colorCounts).sort((a, b) => b[1] - a[1]);
    if (sorted.length > 0) {
      const [r1, g1, b1] = sorted[0][0].split(',').map(Number);
      state.primaryColor = rgbToHex(r1, g1, b1);

      // Pick an accent color with highest contrast / saturation
      let accentHex = '#632FE1';
      if (sorted.length > 1) {
        const [r2, g2, b2] = sorted[Math.min(2, sorted.length - 1)][0].split(',').map(Number);
        accentHex = rgbToHex(r2, g2, b2);
      }
      state.secondaryColor = accentHex;

      updateColorUI();
    }
  }

  function rgbToHex(r, g, b) {
    const toHex = n => Math.min(255, Math.max(0, n)).toString(16).padStart(2, '0');
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
  }

  function updateColorUI() {
    elements.colorInputPrimary.value = state.primaryColor;
    elements.colorInputSecondary.value = state.secondaryColor;
    elements.colorHexPrimary.textContent = state.primaryColor;
    elements.colorHexSecondary.textContent = state.secondaryColor;
    elements.colorGradBar.style.background = `linear-gradient(135deg, ${state.primaryColor}, ${state.secondaryColor})`;
  }

  function setupColorInputs() {
    elements.colorInputPrimary.addEventListener('input', e => {
      state.primaryColor = e.target.value.toUpperCase();
      elements.colorHexPrimary.textContent = state.primaryColor;
      updateColorUI();
    });

    elements.colorInputSecondary.addEventListener('input', e => {
      state.secondaryColor = e.target.value.toUpperCase();
      elements.colorHexSecondary.textContent = state.secondaryColor;
      updateColorUI();
    });
  }

  // ==========================================================================
  // WEBP THUMBNAIL GENERATION
  // ==========================================================================
  function generateWebPThumbnail(img) {
    const targetW = 360;
    const targetH = 640;

    const canvas = elements.canvas;
    canvas.width = targetW;
    canvas.height = targetH;
    const ctx = canvas.getContext('2d');

    // Draw image maintaining cover aspect ratio
    const imgRatio = img.naturalWidth / img.naturalHeight;
    const targetRatio = targetW / targetH;
    let renderW, renderH, offsetX, offsetY;

    if (imgRatio > targetRatio) {
      renderH = targetH;
      renderW = targetH * imgRatio;
      offsetX = -(renderW - targetW) / 2;
      offsetY = 0;
    } else {
      renderW = targetW;
      renderH = targetW / imgRatio;
      offsetX = 0;
      offsetY = -(renderH - targetH) / 2;
    }

    ctx.drawImage(img, offsetX, offsetY, renderW, renderH);

    // Convert to WebP blob with quality 0.85
    canvas.toBlob(blob => {
      if (blob) {
        state.thumbBlob = blob;
        const reader = new FileReader();
        reader.onloadend = () => {
          state.thumbBase64 = reader.result.split(',')[1];
          const kb = (blob.size / 1024).toFixed(1);
          elements.statThumbSize.textContent = `360 × 640 • ${kb} KB WebP`;
        };
        reader.readAsDataURL(blob);
      }
    }, 'image/webp', 0.85);
  }

  // ==========================================================================
  // SIMULATOR & NOTCH INSPECTOR
  // ==========================================================================
  function setupSimulatorEvents() {
    elements.cutoutTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const cutout = tab.dataset.cutout;
        setCutoutOverlay(cutout);
      });
    });
  }

  function setCutoutOverlay(cutout) {
    elements.cutoutTabs.forEach(t => t.classList.remove('active'));
    const matchingTab = Array.from(elements.cutoutTabs).find(t => t.dataset.cutout === cutout);
    if (matchingTab) matchingTab.classList.add('active');

    elements.overlayCenter.style.display = cutout === 'centerHole' ? 'block' : 'none';
    elements.overlayIsland.style.display = cutout === 'dynamicIsland' ? 'flex' : 'none';
    elements.overlayLeft.style.display = cutout === 'leftHole' ? 'block' : 'none';

    if (cutout === 'centerHole') elements.statNotchName.textContent = 'Center Punch';
    else if (cutout === 'dynamicIsland') elements.statNotchName.textContent = 'Dynamic Island';
    else if (cutout === 'leftHole') elements.statNotchName.textContent = 'Left Punch';
    else elements.statNotchName.textContent = 'Full Screen';
  }

  function setupFormEvents() {
    // When Notch Type dropdown changes, update simulator overlay preview
    elements.selectCutoutType.addEventListener('change', () => {
      const type = elements.selectCutoutType.value;
      if (type === 'centerHole') setCutoutOverlay('centerHole');
      else if (type === 'dynamicIsland') setCutoutOverlay('dynamicIsland');
      else if (type === 'leftHole') setCutoutOverlay('leftHole');
      else setCutoutOverlay('none');
    });

    // When simulator tabs are clicked, sync with Notch Type dropdown
    elements.cutoutTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const cutout = tab.dataset.cutout;
        setCutoutOverlay(cutout);
        if (cutout === 'centerHole') elements.selectCutoutType.value = 'centerHole';
        else if (cutout === 'dynamicIsland') elements.selectCutoutType.value = 'dynamicIsland';
        else if (cutout === 'leftHole') elements.selectCutoutType.value = 'leftHole';
        else if (cutout === 'none') elements.selectCutoutType.value = 'universal';
      });
    });

    elements.btnReset.addEventListener('click', () => {
      resetFileSelection();
      elements.inputTitle.value = '';
      elements.inputDescription.value = '';
    });

    elements.btnPublish.addEventListener('click', () => {
      startPublishWorkflow();
    });
  }

  // ==========================================================================
  // GITHUB REST API CLIENT & AUTH
  // ==========================================================================
  function setupSettingsEvents() {
    elements.btnToggleMask.addEventListener('click', () => {
      const type = elements.inputGithubToken.type === 'password' ? 'text' : 'password';
      elements.inputGithubToken.type = type;
      elements.btnToggleMask.textContent = type === 'password' ? '👁️' : '🙈';
    });

    elements.btnSaveSettings.addEventListener('click', async () => {
      const token = elements.inputGithubToken.value.trim();
      const repo = elements.inputRepoOwner.value.trim();
      const branch = elements.inputRepoBranch.value.trim();

      if (!repo) {
        showToast('Repository owner and name is required', 'error');
        return;
      }

      state.token = token;
      state.repo = repo;
      state.branch = branch;

      localStorage.setItem(STORAGE_KEYS.TOKEN, token);
      localStorage.setItem(STORAGE_KEYS.REPO, repo);
      localStorage.setItem(STORAGE_KEYS.BRANCH, branch);

      showToast('Settings saved. Verifying connection...', 'info');
      await testGithubConnection();
    });
  }

  async function testGithubConnection() {
    if (!state.token) {
      updateStatusBadge('unconfigured', 'Token Required');
      return false;
    }

    try {
      const res = await fetch(`https://api.github.com/repos/${state.repo}`, {
        headers: {
          'Authorization': `Bearer ${state.token}`,
          'Accept': 'application/vnd.github+json'
        }
      });

      if (res.ok) {
        const repoData = await res.json();
        updateStatusBadge('connected', `@${repoData.owner.login} • Connected`);
        showToast(`Connected to repository: ${state.repo}`, 'success');
        return true;
      } else if (res.status === 401) {
        updateStatusBadge('error', 'Invalid Token');
        showToast('GitHub token is invalid or expired', 'error');
        return false;
      } else {
        updateStatusBadge('error', 'Repo Not Found');
        showToast(`Repository ${state.repo} not accessible (${res.status})`, 'error');
        return false;
      }
    } catch (err) {
      updateStatusBadge('error', 'Connection Error');
      showToast(`Network error testing connection: ${err.message}`, 'error');
      return false;
    }
  }

  function updateStatusBadge(status, text) {
    elements.statusPill.className = `status-pill ${status}`;
    elements.statusText.textContent = text;
  }

  // ==========================================================================
  // PUBLISH WORKFLOW PIPELINE
  // ==========================================================================
  async function startPublishWorkflow() {
    if (!state.token) {
      showToast('GitHub token is required to publish. Please configure it in settings.', 'error');
      const settingsTab = document.getElementById('tab-settings');
      if (settingsTab) settingsTab.click();
      return;
    }

    if (!state.currentFile || !state.fileDataUrl) {
      showToast('Please select a wallpaper image first', 'error');
      return;
    }

    const title = elements.inputTitle.value.trim();
    if (!title) {
      showToast('Please enter a wallpaper title', 'error');
      elements.inputTitle.focus();
      return;
    }

    // Open Publish Modal
    elements.modalPublish.classList.add('active');
    elements.modalActions.style.display = 'none';
    elements.modalIcon.className = 'modal-icon-wrap';
    elements.modalTitle.textContent = 'Publishing Wallpaper';
    elements.modalDesc.textContent = 'Committing original artwork, WebP thumbnail, and metadata directly to GitHub...';

    resetStepsUI();

    try {
      // Step 1: Ensure WebP Thumbnail is ready
      setStepState(elements.steps.step1, 'running');
      if (!state.thumbBase64) {
        await new Promise(resolve => setTimeout(resolve, 300));
      }
      setStepState(elements.steps.step1, 'done');

      // Step 2: Upload master image
      setStepState(elements.steps.step2, 'running');

      const timestamp = new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
      const randId = Math.floor(100 + Math.random() * 900);
      const uid = `wp_${timestamp}_${randId}`;
      const ext = state.currentFile.name.split('.').pop().toLowerCase() || 'png';
      const masterFilename = `${uid}.${ext}`;

      const category = elements.selectCategory.value;
      const catConfig = CATEGORY_MAP[category] || CATEGORY_MAP['Creative Cutouts'];
      const masterPath = `wallpapers/${catConfig.folder}/${masterFilename}`;

      const masterBase64 = state.fileDataUrl.split(',')[1];
      const masterCommitMsg = `Upload wallpaper: ${title} [${category}]`;

      const masterRes = await commitFileToGithub(masterPath, masterBase64, masterCommitMsg);
      setStepState(elements.steps.step2, 'done');

      // Step 3: Upload WebP thumbnail
      setStepState(elements.steps.step3, 'running');
      const thumbFilename = `${uid}.webp`;
      const thumbPath = `wallpapers/thumbnails/${thumbFilename}`;
      const thumbCommitMsg = `Upload thumbnail: ${thumbFilename}`;

      await commitFileToGithub(thumbPath, state.thumbBase64, thumbCommitMsg);
      setStepState(elements.steps.step3, 'done');

      // Step 4: Fetch, Update, and Commit catalog.json
      setStepState(elements.steps.step4, 'running');
      const catalogPath = 'wallpapers/metadata/catalog.json';
      const existingCatalogData = await fetchFileFromGithub(catalogPath);

      let currentCatalog = [];
      let catalogSha = null;

      if (existingCatalogData) {
        catalogSha = existingCatalogData.sha;
        try {
          const decoded = base64ToUtf8(existingCatalogData.content);
          currentCatalog = JSON.parse(decoded);
        } catch (e) {
          console.warn('Could not parse existing catalog, initializing empty array', e);
          currentCatalog = [];
        }
      }

      // Build new wallpaper entry matching exact app model structure
      const todayFormatted = new Date().toLocaleDateString('en-US', {
        month: 'long',
        day: 'numeric',
        year: 'numeric'
      });

      const rawBase = `https://raw.githubusercontent.com/${state.repo}/${state.branch}`;
      const newItem = {
        id: uid,
        title: title,
        category: category,
        cutoutType: elements.selectCutoutType.value,
        imageUrl: `${rawBase}/${masterPath}`,
        thumbnailUrl: `${rawBase}/${thumbPath}`,
        isMultivariant: false,
        variants: [],
        cutoutVariants: {},
        gradientFallback: [state.primaryColor, state.secondaryColor],
        resolution: elements.inputResolution.value.trim() || '4K Ultra HD',
        dimensions: elements.inputDimensions.value.trim() || '1080 x 2400',
        uploadDate: todayFormatted,
        description: elements.inputDescription.value.trim() || `Curated Ultra HD AMOLED wallpaper engineered for ${category} camera notch.`,
        views: Math.floor(400 + Math.random() * 800),
        isLiked: false,
        aiEngine: 'Curated Artwork'
      };

      // Prepend to top
      currentCatalog.unshift(newItem);

      const updatedCatalogJson = JSON.stringify(currentCatalog, null, 2);
      const catalogBase64 = utf8ToBase64(updatedCatalogJson);
      const catalogCommitMsg = `Register wallpaper: ${title} (${uid})`;

      const catalogCommitRes = await commitFileToGithub(catalogPath, catalogBase64, catalogCommitMsg, catalogSha);
      setStepState(elements.steps.step4, 'done');

      // Success State
      elements.modalIcon.className = 'modal-icon-wrap success';
      elements.modalTitle.textContent = '🎉 Successfully Published!';
      elements.modalDesc.textContent = `"${title}" is now committed to the repository and immediately available in your Vivid Notch mobile app!`;
      elements.modalActions.style.display = 'flex';

      const commitSha = catalogCommitRes?.commit?.sha || masterRes?.commit?.sha;
      if (commitSha) {
        elements.linkCommitView.href = `https://github.com/${state.repo}/commit/${commitSha}`;
        elements.linkCommitView.style.display = 'inline-flex';
      } else {
        elements.linkCommitView.style.display = 'none';
      }

      showToast(`Wallpaper "${title}" published successfully!`, 'success');

      // Reload live catalog in background
      loadLiveCatalog();

    } catch (err) {
      console.error('Publish error:', err);
      showToast(`Upload failed: ${err.message}`, 'error');
      elements.modalTitle.textContent = '❌ Upload Failed';
      elements.modalDesc.textContent = `Error: ${err.message}. Please verify your GitHub token permissions.`;
      elements.modalActions.style.display = 'flex';
      elements.linkCommitView.style.display = 'none';
    }
  }

  function resetStepsUI() {
    Object.values(elements.steps).forEach(s => {
      s.className = 'step-item';
      s.querySelector('.step-icon-state').innerHTML = '⏳';
    });
  }

  function setStepState(stepEl, status) {
    stepEl.className = `step-item ${status}`;
    const icon = stepEl.querySelector('.step-icon-state');
    if (status === 'running') {
      icon.innerHTML = '<span style="display:inline-block;animation:spin 1s linear infinite;">⚙️</span>';
    } else if (status === 'done') {
      icon.innerHTML = '✓';
    } else if (status === 'error') {
      icon.innerHTML = '✕';
    }
  }

  elements.btnModalDone.addEventListener('click', () => {
    elements.modalPublish.classList.remove('active');
    resetFileSelection();
    elements.inputTitle.value = '';
    elements.inputDescription.value = '';
  });

  // ==========================================================================
  // GITHUB COMMITS REST API
  // ==========================================================================
  async function fetchFileFromGithub(path) {
    try {
      const res = await fetch(`https://api.github.com/repos/${state.repo}/contents/${path}?ref=${state.branch}`, {
        headers: {
          'Authorization': `Bearer ${state.token}`,
          'Accept': 'application/vnd.github+json'
        }
      });
      if (res.ok) {
        return await res.json();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  async function commitFileToGithub(path, base64Content, commitMessage, sha = null) {
    const body = {
      message: commitMessage,
      content: base64Content,
      branch: state.branch
    };

    if (sha) {
      body.sha = sha;
    }

    const res = await fetch(`https://api.github.com/repos/${state.repo}/contents/${path}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${state.token}`,
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    });

    if (!res.ok) {
      const errData = await res.json().catch(() => ({}));
      throw new Error(errData.message || `GitHub API error ${res.status}`);
    }

    return await res.json();
  }

  async function deleteFileFromGithub(path, commitMessage) {
    if (!path) return false;
    try {
      const fileData = await fetchFileFromGithub(path);
      if (!fileData || !fileData.sha) return false;

      const res = await fetch(`https://api.github.com/repos/${state.repo}/contents/${path}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${state.token}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: commitMessage,
          sha: fileData.sha,
          branch: state.branch
        })
      });
      return res.ok;
    } catch (err) {
      console.warn(`Could not delete file ${path} from GitHub:`, err);
      return false;
    }
  }

  function getRepoPathFromUrl(url) {
    if (!url) return null;
    const match = url.match(/wallpapers\/(categories|thumbnails)\/[^?#\s]+/);
    return match ? match[0] : null;
  }

  // Unicode safe Base64 helpers
  function utf8ToBase64(str) {
    const bytes = new TextEncoder().encode(str);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }

  function base64ToUtf8(base64) {
    const binary = atob(base64.replace(/\s/g, ''));
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return new TextDecoder().decode(bytes);
  }

  // ==========================================================================
  // LIVE CATALOG MANAGER (TAB 2)
  // ==========================================================================
  async function loadLiveCatalog() {
    elements.catalogGrid.innerHTML = `
      <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: var(--text-muted);">
        <p>Loading catalog from GitHub repository...</p>
      </div>
    `;

    try {
      const url = `https://raw.githubusercontent.com/${state.repo}/${state.branch}/wallpapers/metadata/catalog.json?t=${Date.now()}`;
      const res = await fetch(url);
      if (!res.ok) throw new Error('Catalog file not found');
      state.catalog = await res.json();
      elements.catalogBadge.textContent = state.catalog.length;
      renderCatalogGrid();
    } catch (e) {
      elements.catalogGrid.innerHTML = `
        <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: var(--text-muted);">
          <p>No catalog found or network error (${escapeHtml(e.message)}).</p>
        </div>
      `;
    }
  }

  function setupCatalogEvents() {
    elements.catalogSearch.addEventListener('input', e => {
      state.searchQuery = e.target.value.toLowerCase().trim();
      renderCatalogGrid();
    });

    elements.catalogFilterPills.forEach(pill => {
      pill.addEventListener('click', () => {
        elements.catalogFilterPills.forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        state.activeFilter = pill.dataset.filter;
        renderCatalogGrid();
      });
    });

    // Select All / Deselect All
    if (elements.btnToolbarSelectAll) {
      elements.btnToolbarSelectAll.addEventListener('click', toggleSelectAllVisible);
    }
    if (elements.btnToggleSelectAll) {
      elements.btnToggleSelectAll.addEventListener('click', toggleSelectAllVisible);
    }

    // Clear Selection
    if (elements.btnClearSelection) {
      elements.btnClearSelection.addEventListener('click', () => {
        state.selectedIds.clear();
        updateBatchBar();
        renderCatalogGrid();
      });
    }

    // Batch Delete Button
    if (elements.btnDeleteSelected) {
      elements.btnDeleteSelected.addEventListener('click', batchDeleteWallpapers);
    }
  }

  function getVisibleWallpapers() {
    let items = state.catalog;
    if (state.activeFilter !== 'All') {
      items = items.filter(item => item.category === state.activeFilter);
    }
    if (state.searchQuery) {
      items = items.filter(item => {
        const title = (item.title || '').toLowerCase();
        const cat = (item.category || '').toLowerCase();
        const id = (item.id || '').toLowerCase();
        return title.includes(state.searchQuery) || cat.includes(state.searchQuery) || id.includes(state.searchQuery);
      });
    }
    return items;
  }

  function toggleSelectAllVisible() {
    const visible = getVisibleWallpapers();
    const visibleIds = visible.map(w => w.id);
    const allSelected = visibleIds.length > 0 && visibleIds.every(id => state.selectedIds.has(id));

    if (allSelected) {
      visibleIds.forEach(id => state.selectedIds.delete(id));
    } else {
      visibleIds.forEach(id => state.selectedIds.add(id));
    }

    updateBatchBar();
    renderCatalogGrid();
  }

  function updateBatchBar() {
    const count = state.selectedIds.size;
    if (!elements.batchBar) return;

    if (count > 0) {
      elements.batchBar.style.display = 'flex';
      elements.batchCountText.textContent = `${count} wallpaper${count > 1 ? 's' : ''} marked`;
      if (elements.btnToolbarSelectAll) {
        const visible = getVisibleWallpapers();
        const allSelected = visible.length > 0 && visible.every(w => state.selectedIds.has(w.id));
        elements.btnToolbarSelectAll.textContent = allSelected ? 'Deselect All' : 'Select All';
      }
    } else {
      elements.batchBar.style.display = 'none';
      if (elements.btnToolbarSelectAll) {
        elements.btnToolbarSelectAll.textContent = 'Select All';
      }
    }
  }

  function renderCatalogGrid() {
    const items = getVisibleWallpapers();

    if (items.length === 0) {
      elements.catalogGrid.innerHTML = '';
      elements.catalogEmpty.style.display = 'flex';
      updateBatchBar();
      return;
    }

    elements.catalogEmpty.style.display = 'none';

    elements.catalogGrid.innerHTML = items.map(item => {
      const thumbUrl = item.thumbnailUrl || item.imageUrl;
      const gradColors = item.gradientFallback || ['#0F172A', '#38BDF8'];
      const isSelected = state.selectedIds.has(item.id);

      return `
        <div class="wallpaper-card ${isSelected ? 'is-selected' : ''}" data-id="${escapeHtml(item.id)}">
          <div class="card-select-wrap">
            <input type="checkbox" class="card-checkbox" data-id="${escapeHtml(item.id)}" ${isSelected ? 'checked' : ''} title="Mark wallpaper">
          </div>
          <div class="card-thumb-wrap">
            <img class="card-thumb-img" src="${escapeHtml(thumbUrl)}" loading="lazy" alt="${escapeHtml(item.title)}">
            <span class="card-badge" style="left: 36px;">${escapeHtml(item.category)}</span>
            <div class="card-actions-overlay">
              <button class="card-action-btn btn-delete-wp" data-id="${escapeHtml(item.id)}" title="Delete Wallpaper">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="3 6 5 6 21 6"/>
                  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                </svg>
              </button>
            </div>
          </div>
          <div class="card-body">
            <h4 class="card-title" title="${escapeHtml(item.title)}">${escapeHtml(item.title)}</h4>
            <div class="card-meta-row">
              <span>${escapeHtml(item.dimensions || '1080 x 2400')}</span>
              <div class="card-colors">
                <span class="card-color-dot" style="background: ${escapeHtml(gradColors[0])};"></span>
                <span class="card-color-dot" style="background: ${escapeHtml(gradColors[1] || gradColors[0])};"></span>
              </div>
            </div>
          </div>
        </div>
      `;
    }).join('');

    // Attach Card Selection & Checkbox Listeners
    elements.catalogGrid.querySelectorAll('.wallpaper-card').forEach(card => {
      card.addEventListener('click', e => {
        // If clicking delete button, don't toggle selection
        if (e.target.closest('.btn-delete-wp')) return;

        const id = card.dataset.id;
        const checkbox = card.querySelector('.card-checkbox');

        if (state.selectedIds.has(id)) {
          state.selectedIds.delete(id);
          card.classList.remove('is-selected');
          if (checkbox) checkbox.checked = false;
        } else {
          state.selectedIds.add(id);
          card.classList.add('is-selected');
          if (checkbox) checkbox.checked = true;
        }

        updateBatchBar();
      });
    });

    // Checkbox click listener
    elements.catalogGrid.querySelectorAll('.card-checkbox').forEach(cb => {
      cb.addEventListener('click', e => {
        e.stopPropagation();
        const id = cb.dataset.id;
        const card = cb.closest('.wallpaper-card');
        if (cb.checked) {
          state.selectedIds.add(id);
          if (card) card.classList.add('is-selected');
        } else {
          state.selectedIds.delete(id);
          if (card) card.classList.remove('is-selected');
        }
        updateBatchBar();
      });
    });

    // Attach Single Delete Listeners
    elements.catalogGrid.querySelectorAll('.btn-delete-wp').forEach(btn => {
      btn.addEventListener('click', e => {
        e.stopPropagation();
        const id = btn.dataset.id;
        deleteWallpaperFromCatalog(id);
      });
    });

    updateBatchBar();
  }

  async function batchDeleteWallpapers() {
    if (!state.token) {
      showToast('GitHub token required to delete wallpapers', 'error');
      const settingsTab = document.getElementById('tab-settings');
      if (settingsTab) settingsTab.click();
      return;
    }

    const count = state.selectedIds.size;
    if (count === 0) {
      showToast('No wallpapers marked to delete', 'info');
      return;
    }

    if (!confirm(`Are you sure you want to permanently remove ${count} marked wallpaper${count > 1 ? 's' : ''} and their thumbnails from the repository?`)) {
      return;
    }

    showToast(`Deleting ${count} wallpapers & thumbnails from repository...`, 'info');

    try {
      // 1. Concurrently delete all thumbnail and master image files from repo
      const fileDeletePromises = [];
      for (const id of state.selectedIds) {
        const item = state.catalog.find(w => w.id === id);
        if (item) {
          const thumbPath = getRepoPathFromUrl(item.thumbnailUrl) || `wallpapers/thumbnails/${id}.webp`;
          fileDeletePromises.push(deleteFileFromGithub(thumbPath, `Delete thumbnail: ${id}`));

          const masterPath = getRepoPathFromUrl(item.imageUrl);
          if (masterPath) {
            fileDeletePromises.push(deleteFileFromGithub(masterPath, `Delete master image: ${id}`));
          }
        }
      }

      await Promise.allSettled(fileDeletePromises);

      // 2. Remove all from catalog.json
      const catalogPath = 'wallpapers/metadata/catalog.json';
      const fileData = await fetchFileFromGithub(catalogPath);
      if (!fileData) throw new Error('Could not fetch catalog.json from GitHub');

      const currentCatalog = JSON.parse(base64ToUtf8(fileData.content));
      const updated = currentCatalog.filter(w => !state.selectedIds.has(w.id));

      const jsonStr = JSON.stringify(updated, null, 2);
      const base64 = utf8ToBase64(jsonStr);

      await commitFileToGithub(catalogPath, base64, `Batch remove ${count} wallpapers & thumbnails`, fileData.sha);

      state.catalog = updated;
      state.selectedIds.clear();
      elements.catalogBadge.textContent = state.catalog.length;

      updateBatchBar();
      renderCatalogGrid();
      showToast(`Successfully deleted ${count} wallpaper${count > 1 ? 's' : ''} and their thumbnails!`, 'success');
    } catch (err) {
      showToast(`Failed to delete: ${err.message}`, 'error');
    }
  }

  async function deleteWallpaperFromCatalog(id) {
    if (!state.token) {
      showToast('GitHub token required to delete wallpapers', 'error');
      const settingsTab = document.getElementById('tab-settings');
      if (settingsTab) settingsTab.click();
      return;
    }

    const item = state.catalog.find(w => w.id === id);
    const title = item ? item.title : id;

    if (!confirm(`Are you sure you want to permanently remove "${title}" and its thumbnail from the repository?`)) {
      return;
    }

    showToast(`Removing "${title}" and thumbnail from repository...`, 'info');

    try {
      if (item) {
        // 1. Delete thumbnail file from repo
        const thumbPath = getRepoPathFromUrl(item.thumbnailUrl) || `wallpapers/thumbnails/${id}.webp`;
        await deleteFileFromGithub(thumbPath, `Delete thumbnail: ${id}`);

        // 2. Delete master image file from repo
        const masterPath = getRepoPathFromUrl(item.imageUrl);
        if (masterPath) {
          await deleteFileFromGithub(masterPath, `Delete master image: ${id}`);
        }
      }

      // 3. Remove from catalog.json
      const catalogPath = 'wallpapers/metadata/catalog.json';
      const fileData = await fetchFileFromGithub(catalogPath);
      if (!fileData) throw new Error('Could not fetch catalog.json from GitHub');

      const currentCatalog = JSON.parse(base64ToUtf8(fileData.content));
      const updated = currentCatalog.filter(w => w.id !== id);

      const jsonStr = JSON.stringify(updated, null, 2);
      const base64 = utf8ToBase64(jsonStr);

      await commitFileToGithub(catalogPath, base64, `Remove wallpaper: ${title} (${id})`, fileData.sha);

      state.catalog = updated;
      state.selectedIds.delete(id);
      elements.catalogBadge.textContent = state.catalog.length;

      updateBatchBar();
      renderCatalogGrid();
      showToast(`Removed "${title}" and deleted thumbnail successfully!`, 'success');
    } catch (err) {
      showToast(`Failed to delete: ${err.message}`, 'error');
    }
  }

  // Run on DOM ready
  document.addEventListener('DOMContentLoaded', init);

})();
