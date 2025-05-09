/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./assets/src/js/api.js":
/*!******************************!*\
  !*** ./assets/src/js/api.js ***!
  \******************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/**
 * List API on backend
 *
 * @since 4.2.6
 * @version 1.0.1
 */

const lplistAPI = {};
let lp_rest_url;
if ('undefined' !== typeof lpDataAdmin) {
  lp_rest_url = lpDataAdmin.lp_rest_url;
  lplistAPI.admin = {
    apiAdminNotice: lpDataAdmin.lp_rest_url + 'lp/v1/admin/tools/admin-notices',
    apiAdminOrderStatic: lpDataAdmin.lp_rest_url + 'lp/v1/orders/statistic',
    apiAddons: lpDataAdmin.lp_rest_url + 'lp/v1/addon/all',
    apiAddonAction: lpDataAdmin.lp_rest_url + 'lp/v1/addon/action-n',
    apiAddonsPurchase: lpDataAdmin.lp_rest_url + 'lp/v1/addon/info-addons-purchase',
    apiSearchCourses: lpDataAdmin.lp_rest_url + 'lp/v1/admin/tools/search-course',
    apiSearchUsers: lpDataAdmin.lp_rest_url + 'lp/v1/admin/tools/search-user',
    apiAssignUserCourse: lpDataAdmin.lp_rest_url + 'lp/v1/admin/tools/assign-user-course',
    apiUnAssignUserCourse: lpDataAdmin.lp_rest_url + 'lp/v1/admin/tools/unassign-user-course'
  };
}
if ('undefined' !== typeof lpData) {
  lp_rest_url = lpData.lp_rest_url;
  lplistAPI.frontend = {
    apiWidgets: lpData.lp_rest_url + 'lp/v1/widgets/api',
    apiCourses: lpData.lp_rest_url + 'lp/v1/courses/archive-course',
    apiAJAX: lpData.lp_rest_url + 'lp/v1/load_content_via_ajax/',
    apiProfileCoverImage: lpData.lp_rest_url + 'lp/v1/profile/cover-image'
  };
}
if (lp_rest_url) {
  lplistAPI.apiAJAX = lp_rest_url + 'lp/v1/load_content_via_ajax/';
  lplistAPI.apiCourses = lp_rest_url + 'lp/v1/courses/';
}
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (lplistAPI);

/***/ }),

/***/ "./assets/src/js/utils.js":
/*!********************************!*\
  !*** ./assets/src/js/utils.js ***!
  \********************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   listenElementCreated: () => (/* binding */ listenElementCreated),
/* harmony export */   listenElementViewed: () => (/* binding */ listenElementViewed),
/* harmony export */   lpAddQueryArgs: () => (/* binding */ lpAddQueryArgs),
/* harmony export */   lpAjaxParseJsonOld: () => (/* binding */ lpAjaxParseJsonOld),
/* harmony export */   lpClassName: () => (/* binding */ lpClassName),
/* harmony export */   lpFetchAPI: () => (/* binding */ lpFetchAPI),
/* harmony export */   lpGetCurrentURLNoParam: () => (/* binding */ lpGetCurrentURLNoParam),
/* harmony export */   lpOnElementReady: () => (/* binding */ lpOnElementReady),
/* harmony export */   lpSetLoadingEl: () => (/* binding */ lpSetLoadingEl),
/* harmony export */   lpShowHideEl: () => (/* binding */ lpShowHideEl)
/* harmony export */ });
/**
 * Utils functions
 *
 * @param url
 * @param data
 * @param functions
 * @since 4.2.5.1
 * @version 1.0.3
 */
const lpClassName = {
  hidden: 'lp-hidden',
  loading: 'loading'
};
const lpFetchAPI = (url, data = {}, functions = {}) => {
  if ('function' === typeof functions.before) {
    functions.before();
  }
  fetch(url, {
    method: 'GET',
    ...data
  }).then(response => response.json()).then(response => {
    if ('function' === typeof functions.success) {
      functions.success(response);
    }
  }).catch(err => {
    if ('function' === typeof functions.error) {
      functions.error(err);
    }
  }).finally(() => {
    if ('function' === typeof functions.completed) {
      functions.completed();
    }
  });
};

/**
 * Get current URL without params.
 *
 * @since 4.2.5.1
 */
const lpGetCurrentURLNoParam = () => {
  let currentUrl = window.location.href;
  const hasParams = currentUrl.includes('?');
  if (hasParams) {
    currentUrl = currentUrl.split('?')[0];
  }
  return currentUrl;
};
const lpAddQueryArgs = (endpoint, args) => {
  const url = new URL(endpoint);
  Object.keys(args).forEach(arg => {
    url.searchParams.set(arg, args[arg]);
  });
  return url;
};

/**
 * Listen element viewed.
 *
 * @param el
 * @param callback
 * @since 4.2.5.8
 */
const listenElementViewed = (el, callback) => {
  const observerSeeItem = new IntersectionObserver(function (entries) {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        callback(entry);
      }
    }
  });
  observerSeeItem.observe(el);
};

/**
 * Listen element created.
 *
 * @param callback
 * @since 4.2.5.8
 */
const listenElementCreated = callback => {
  const observerCreateItem = new MutationObserver(function (mutations) {
    mutations.forEach(function (mutation) {
      if (mutation.addedNodes) {
        mutation.addedNodes.forEach(function (node) {
          if (node.nodeType === 1) {
            callback(node);
          }
        });
      }
    });
  });
  observerCreateItem.observe(document, {
    childList: true,
    subtree: true
  });
  // End.
};

/**
 * Listen element created.
 *
 * @param selector
 * @param callback
 * @since 4.2.7.1
 */
const lpOnElementReady = (selector, callback) => {
  const element = document.querySelector(selector);
  if (element) {
    callback(element);
    return;
  }
  const observer = new MutationObserver((mutations, obs) => {
    const element = document.querySelector(selector);
    if (element) {
      obs.disconnect();
      callback(element);
    }
  });
  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
};

// Parse JSON from string with content include LP_AJAX_START.
const lpAjaxParseJsonOld = data => {
  if (typeof data !== 'string') {
    return data;
  }
  const m = String.raw({
    raw: data
  }).match(/<-- LP_AJAX_START -->(.*)<-- LP_AJAX_END -->/s);
  try {
    if (m) {
      data = JSON.parse(m[1].replace(/(?:\r\n|\r|\n)/g, ''));
    } else {
      data = JSON.parse(data);
    }
  } catch (e) {
    data = {};
  }
  return data;
};

// status 0: hide, 1: show
const lpShowHideEl = (el, status = 0) => {
  if (!el) {
    return;
  }
  if (!status) {
    el.classList.add(lpClassName.hidden);
  } else {
    el.classList.remove(lpClassName.hidden);
  }
};

// status 0: hide, 1: show
const lpSetLoadingEl = (el, status) => {
  if (!el) {
    return;
  }
  if (!status) {
    el.classList.remove(lpClassName.loading);
  } else {
    el.classList.add(lpClassName.loading);
  }
};


/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
/*!**********************************************!*\
  !*** ./assets/src/js/admin/admin-notices.js ***!
  \**********************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _utils_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../utils.js */ "./assets/src/js/utils.js");
/* harmony import */ var _api_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../api.js */ "./assets/src/js/api.js");
/**
 * Script handle admin notices.
 *
 * @since 4.1.7.3.2
 * @version 1.0.2
 */


let elLPAdminNotices = null;
let dataHtml = null;
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const tab = urlParams.get('tab');
const notifyAddonsNewVersion = () => {
  try {
    const elAdminMenu = document.querySelector('#adminmenu');
    if (!elAdminMenu) {
      return;
    }
    const elTabLP = elAdminMenu.querySelector('#toplevel_page_learn_press');
    if (!elTabLP) {
      return;
    }
    const elTabLPName = elTabLP.querySelector('.wp-menu-name');
    if (!elTabLPName) {
      return;
    }
    const elAddonsNewVerTotal = document.querySelector('input[name=lp-addons-new-version-totals]');
    if (!elAddonsNewVerTotal) {
      return;
    }
    const htmlNotifyLP = `<span class="tab-lp-admin-notice"></span>`;
    elTabLPName.insertAdjacentHTML('beforeend', htmlNotifyLP);
    const elTabLPAddons = elTabLP.querySelector('a[href="admin.php?page=learn-press-addons"]');
    if (!elTabLPAddons) {
      return;
    }
    const total = elAddonsNewVerTotal.value;
    const html = `<span style="margin-left: 5px" class="update-plugins">${total}</span>`;
    elTabLPAddons.setAttribute('href', 'admin.php?page=learn-press-addons&tab=update');
    elTabLPAddons.insertAdjacentHTML('beforeend', html);
  } catch (e) {
    console.log(e);
  }
};
const callAdminNotices = (set = '') => {
  if (!lpGlobalSettings.is_admin) {
    return;
  }
  let params = tab ? `?tab=${tab}` : '';
  params += set ? (tab ? '&' : '?') + `${set}` : '';
  fetch(_api_js__WEBPACK_IMPORTED_MODULE_1__["default"].admin.apiAdminNotice + params, {
    method: 'POST',
    headers: {
      'X-WP-Nonce': lpGlobalSettings.nonce
    }
  }).then(res => res.json()).then(res => {
    // console.log(data);

    const {
      status,
      message,
      data
    } = res;
    if (status === 'success') {
      if ('Dismissed!' !== message) {
        dataHtml = data.content;
        if (dataHtml.length === 0) {
          elLPAdminNotices.style.display = 'none';
        } else {
          elLPAdminNotices.innerHTML = dataHtml;
          elLPAdminNotices.style.display = 'block';
          // Handle notify addons new version.
          notifyAddonsNewVersion();
        }
      }
    } else {
      dataHtml = message;
    }
  }).catch(err => {
    console.log(err);
  });
};

// Listen element ready
(0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpOnElementReady)('.lp-admin-notices', () => {
  elLPAdminNotices = document.querySelector('.lp-admin-notices');
  callAdminNotices();
});

/*** Events ***/
document.addEventListener('click', e => {
  const el = e.target;
  if (el.classList.contains('btn-lp-notice-dismiss')) {
    e.preventDefault();

    // eslint-disable-next-line no-alert
    if (confirm('Are you sure you want to dismiss this notice?')) {
      const parent = el.closest('.lp-notice');
      callAdminNotices(`dismiss=${el.getAttribute('data-dismiss')}`);
      parent.remove();
      if (elLPAdminNotices.querySelectorAll('.lp-notice').length === 0) {
        elLPAdminNotices.style.display = 'none';
      }
    }
  }
});
/******/ })()
;
//# sourceMappingURL=admin-notices.js.map