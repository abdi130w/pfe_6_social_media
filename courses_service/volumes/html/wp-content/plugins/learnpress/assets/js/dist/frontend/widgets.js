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
/*!*******************************************!*\
  !*** ./assets/src/js/frontend/widgets.js ***!
  \*******************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _utils_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../utils.js */ "./assets/src/js/utils.js");
/* harmony import */ var _api__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../api */ "./assets/src/js/api.js");


function widgetRestAPI() {
  const widgets = document.querySelectorAll('.learnpress-widget-wrapper:not(.loaded)');
  const widgetBlocks = document.querySelectorAll('.learnpress-block-widget-wrapper:not(.loaded)');
  if (!widgets.length && !widgetBlocks.length) {
    return;
  }
  const getResponse = ele => {
    const lang = lpData.urlParams.lang ? `?lang=${lpData.urlParams.lang}` : '';
    const widgetData = ele.dataset.widget ? JSON.parse(ele.dataset.widget) : '';
    const url = _api__WEBPACK_IMPORTED_MODULE_1__["default"].frontend.apiWidgets + lang;
    const paramsFetch = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        ...widgetData,
        ...{
          params_url: lpData.urlParams
        }
      })
    };
    if (0 !== parseInt(lpData.user_id)) {
      paramsFetch.headers['X-WP-Nonce'] = lpData.nonce;
    }
    const callBack = {
      before: () => {},
      success: res => {
        const {
          data,
          status,
          message
        } = res;
        if (data && status === 'success') {
          ele.insertAdjacentHTML('afterbegin', data);
        } else if (message) {
          ele.insertAdjacentHTML('afterbegin', `<div class="lp-ajax-message error" style="display:block">${message}</div>`);
        }
        const elBtnDone = ele.querySelector('.course-filter-submit.lp-btn-done');
        if (elBtnDone) {
          if (window.outerWidth <= 991) {
            (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elBtnDone, 1);
          } else {
            (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elBtnDone, 0);
          }
        }
      },
      error: error => {},
      completed: () => {
        //delete ele.dataset.widget;
        const elSkeleton = ele.querySelector('.lp-skeleton-animation');
        if (elSkeleton) {
          elSkeleton.remove();
        }

        // Set temporary count course fields filter selected
        const classCourseFilter = 'lp-form-course-filter';
        const courseFilter = document.querySelector(`.${classCourseFilter}`);
        if (courseFilter) {
          window.lpCourseFilter.countFieldsSelected(courseFilter);
        }
      }
    };

    // Call API load widget
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpFetchAPI)(url, paramsFetch, callBack);
  };
  if (widgets.length) {
    widgets.forEach(ele => {
      ele.classList.add('loaded');
      if (ele.classList.contains('learnpress-widget-wrapper__restapi')) {
        getResponse(ele);
      }
    });
  }
  if (widgetBlocks.length) {
    widgetBlocks.forEach(ele => {
      ele.classList.add('loaded');
      if (ele.classList.contains('learnpress-widget-wrapper__restapi')) {
        getResponse(ele);
      }
    });
  }
}
widgetRestAPI();

// Case 2: readystatechange, find all elements with the class '.lp-load-ajax-element' not have class 'loaded'
document.addEventListener('readystatechange', event => {
  widgetRestAPI();
});

// Case 3: DOMContentLoaded, find all elements with the class '.lp-load-ajax-element' not have class 'loaded'
document.addEventListener('DOMContentLoaded', () => {
  widgetRestAPI();
});
/******/ })()
;
//# sourceMappingURL=widgets.js.map