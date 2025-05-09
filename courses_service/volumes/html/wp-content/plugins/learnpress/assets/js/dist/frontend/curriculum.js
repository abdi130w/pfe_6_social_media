/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

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
  !*** ./assets/src/js/frontend/curriculum.js ***!
  \**********************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _utils_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../utils.js */ "./assets/src/js/utils.js");
/**
 * Handle curriculum
 *
 * @version 1.0.1
 * @since 4.2.7.6
 */



// Events
/**
 * 1. Handle click section header
 */
document.addEventListener('click', e => {
  const target = e.target;
  const elSectionHeader = target.closest('.course-section-header');
  if (elSectionHeader) {
    const elSection = elSectionHeader.closest('.course-section');
    if (!elSection) {
      return;
    }
    e.preventDefault();
    toggleSection(elSection);
  }
  if (target.classList.contains('course-toggle-all-sections')) {
    e.preventDefault();
    toggleSectionAll(target);
  }
});

/**
 * 1. Handle search title course
 */
document.addEventListener('keyup', e => {
  const target = e.target;

  // code compare html with name = search
  if (target.name === 's' && target.closest('form.search-course')) {
    const value = target.value;
    searchItemCourse(value);
  }
});

/**
 * 1. Handle submit form search
 */
document.addEventListener('submit', e => {
  const target = e.target;

  // Stop enter form search
  if (target.closest('form.search-course')) {
    e.preventDefault();
  }
});
// End events

const toggleSectionAll = elToggleAllSections => {
  const elCurriculum = elToggleAllSections.closest('.lp-course-curriculum');
  const elSections = elCurriculum.querySelectorAll('.course-section');
  const elExpand = elCurriculum.querySelector('.course-toggle-all-sections');
  const elCollapse = elCurriculum.querySelector('.course-toggle-all-sections.lp-collapse');
  if (elToggleAllSections.classList.contains('lp-collapse')) {
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elExpand, 1);
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elCollapse, 0);
    elSections.forEach(el => {
      if (!el.classList.contains('lp-collapse')) {
        el.classList.add('lp-collapse');
      }
    });
  } else {
    elSections.forEach(el => {
      (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elExpand, 0);
      (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elCollapse, 1);
      if (el.classList.contains('lp-collapse')) {
        el.classList.remove('lp-collapse');
      }
    });
  }
};
const toggleSection = elSection => {
  const elCurriculum = elSection.closest('.lp-course-curriculum');

  // Toggle section
  elSection.classList.toggle('lp-collapse');

  // Check all sections collapsed
  checkAllSectionsCollapsed(elCurriculum);
};
const checkAllSectionsCollapsed = elCurriculum => {
  const elSections = elCurriculum.querySelectorAll('.course-section');
  const elExpand = elCurriculum.querySelector('.course-toggle-all-sections');
  const elCollapse = elCurriculum.querySelector('.course-toggle-all-sections.lp-collapse');
  let isAllCollapsed = false;
  elSections.forEach(el => {
    if (el.classList.contains('lp-collapse')) {
      isAllCollapsed = true;
    }
  });
  if (isAllCollapsed) {
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elExpand, 1);
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elCollapse, 0);
  } else {
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elExpand, 0);
    (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elCollapse, 1);
  }
};

// Search title item of course by text
const searchItemCourse = text => {
  const elCurriculum = document.querySelector('.lp-course-curriculum');
  const elSections = elCurriculum.querySelectorAll('.course-section');
  elSections.forEach(elSection => {
    let found = false;
    elSection.querySelectorAll('.course-item').forEach(elItem => {
      const elSection = elItem.closest('.course-section');
      const titleItem = elItem.querySelector('.course-item-title').textContent;
      if (!searchText(titleItem, text)) {
        (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elItem, 0);
        elItem.classList.add('lp-hide');
      } else {
        found = true;
        (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elItem, 1);
        elSection.classList.remove('lp-collapse');
      }
    });
    if (!found) {
      (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elSection, 0);
    } else {
      (0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpShowHideEl)(elSection, 1);
    }
  });
};
const normalizeVietnamese = str => {
  return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
};

/**
 * Search string on text
 * Logic:
 * User enter text: "11 lesson"
 * JS will search string has word "lesson" and "11"
 * Result: "Lesson 11: Introduction"
 * Result: "11 lesson: Introduction"
 *
 * @param text
 * @param searchTerm
 */
const searchText = (text, searchTerm) => {
  const normalizedText = normalizeVietnamese(text.toLowerCase());
  const searchTermArr = searchTerm.trim().split(' ');
  const length = searchTermArr.length;
  let found = 0;
  searchTermArr.forEach(term => {
    const normalizedSearchTerm = normalizeVietnamese(term.toLowerCase());
    const regex = new RegExp(normalizedSearchTerm, 'gi');
    if (regex.test(normalizedText)) {
      found++;
    }
  });
  return found === length;
};

// Scroll to item viewing
const scrollToItemViewing = elCurriculum => {
  const elItemCurrent = elCurriculum.querySelector('li.current');
  if (!elItemCurrent) {
    return;
  }
  elItemCurrent.scrollIntoView({
    behavior: 'smooth'
  });
};
(0,_utils_js__WEBPACK_IMPORTED_MODULE_0__.lpOnElementReady)('.lp-course-curriculum', elCurriculum => {
  checkAllSectionsCollapsed(elCurriculum);

  // Set interval to check if item viewing is changed
  const interval = setInterval(() => {
    if (document.readyState === 'complete') {
      clearInterval(interval);
      scrollToItemViewing(elCurriculum);
    }
  }, 300);
});
/******/ })()
;
//# sourceMappingURL=curriculum.js.map