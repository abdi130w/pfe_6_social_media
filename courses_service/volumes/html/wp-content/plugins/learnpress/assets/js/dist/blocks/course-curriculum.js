/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./assets/src/apps/js/blocks/course-elements/course-curriculum/edit.js":
/*!*****************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-curriculum/edit.js ***!
  \*****************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/i18n */ "@wordpress/i18n");
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @wordpress/block-editor */ "@wordpress/block-editor");
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2__);



const Edit = props => {
  const blockProps = (0,_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2__.useBlockProps)();
  return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(react__WEBPACK_IMPORTED_MODULE_0__.Fragment, null, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    ...blockProps
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "lp-course-curriculum"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("h3", {
    className: "lp-course-curriculum__title"
  }, (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__.__)('Curriculum', 'learnpress')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-curriculum-info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("ul", {
    className: "course-curriculum-info__left"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-count-section"
  }, '2 Sections'), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-count-lesson"
  }, '3 Lessons'), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-duration"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-duration"
  }, '3 Weeks'))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-curriculum-info__right"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-toggle-all-sections"
  }, 'Expand all sections'))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-curriculum"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("ul", {
    className: "course-sections"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-section"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section-header"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "section-toggle"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("i", {
    className: "lp-icon-angle-up"
  })), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section-info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section__title"
  }, 'Section 1')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "section-count-items"
  }, '3')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("ul", {
    className: "course-section__items"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-item"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("a", {
    className: "course-item__link"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-item-ico lp_lesson"
  })), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__content"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__left"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item-title"
  }, 'What is LearnPress?')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__right"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "duration"
  }, '20 Minutes'))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__status"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-item-ico in-progress"
  })))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-item "
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("a", {
    className: "course-item__link"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-item-ico lp_lesson"
  })), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__content"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__left"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item-title"
  }, 'How to use LearnPress?')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__right"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "duration"
  }, '60 Minutes'))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__status"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-item-ico preview"
  })))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-item "
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("a", {
    className: "course-item__link"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-item-ico lp_quiz"
  })), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__content"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__left"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item-title"
  }, 'Demo the Quiz of LearnPress')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__right"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "duration"
  }, '10 Minutes'), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "question-count"
  }, '4 Questions'))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-item__status"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "course-item-ico locked"
  })))))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    className: "course-section lp-collapse"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section-header"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "section-toggle"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("i", {
    className: "lp-icon-angle-down"
  })), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section-info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section__title"
  }, 'Section 2'), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "course-section__description"
  }, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "section-count-items"
  }, '10'))))))));
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (Edit);

/***/ }),

/***/ "./assets/src/apps/js/blocks/course-elements/course-curriculum/save.js":
/*!*****************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-curriculum/save.js ***!
  \*****************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   save: () => (/* binding */ save)
/* harmony export */ });
const save = props => null;

/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "React" ***!
  \************************/
/***/ ((module) => {

module.exports = window["React"];

/***/ }),

/***/ "@wordpress/block-editor":
/*!*************************************!*\
  !*** external ["wp","blockEditor"] ***!
  \*************************************/
/***/ ((module) => {

module.exports = window["wp"]["blockEditor"];

/***/ }),

/***/ "@wordpress/blocks":
/*!********************************!*\
  !*** external ["wp","blocks"] ***!
  \********************************/
/***/ ((module) => {

module.exports = window["wp"]["blocks"];

/***/ }),

/***/ "@wordpress/i18n":
/*!******************************!*\
  !*** external ["wp","i18n"] ***!
  \******************************/
/***/ ((module) => {

module.exports = window["wp"]["i18n"];

/***/ }),

/***/ "./assets/src/apps/js/blocks/course-elements/course-curriculum/block.json":
/*!********************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-curriculum/block.json ***!
  \********************************************************************************/
/***/ ((module) => {

module.exports = /*#__PURE__*/JSON.parse('{"$schema":"https://schemas.wp.org/trunk/block.json","apiVersion":3,"name":"learnpress/course-curriculum","title":"Course Curriculum","category":"learnpress-course-elements","description":"Renders template Curriculum Course PHP templates.","textdomain":"learnpress","keywords":["curriculum single course","learnpress"],"usesContext":[],"supports":{"align":["wide","full"],"html":false,"typography":{"fontSize":true,"lineHeight":false,"fontWeight":true,"__experimentalFontFamily":false,"__experimentalTextDecoration":false,"__experimentalFontStyle":false,"__experimentalFontWeight":true,"__experimentalLetterSpacing":false,"__experimentalTextTransform":true,"__experimentalDefaultControls":{"fontSize":true}},"color":{"background":false,"text":true,"link":false,"heading":true,"gradients":false,"__experimentalDefaultControls":{"text":true,"h3":true}},"spacing":{"padding":true,"margin":true,"__experimentalDefaultControls":{"margin":false,"padding":false}}}}');

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
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
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
/*!******************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-curriculum/index.js ***!
  \******************************************************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _edit__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./edit */ "./assets/src/apps/js/blocks/course-elements/course-curriculum/edit.js");
/* harmony import */ var _save__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./save */ "./assets/src/apps/js/blocks/course-elements/course-curriculum/save.js");
/* harmony import */ var _block_json__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./block.json */ "./assets/src/apps/js/blocks/course-elements/course-curriculum/block.json");
/* harmony import */ var _wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @wordpress/blocks */ "@wordpress/blocks");
/* harmony import */ var _wordpress_blocks__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__);

/**
 * Register block course curriculum.
 */




(0,_wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__.registerBlockType)('learnpress/course-curriculum', {
  ..._block_json__WEBPACK_IMPORTED_MODULE_3__,
  icon: {
    src: (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("svg", {
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      width: "24",
      height: "24",
      className: "wc-block-editor-components-block-icon",
      "aria-hidden": "true",
      focusable: "false"
    }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("path", {
      fillRule: "evenodd",
      d: "M16.83 6.342l.602.3.625-.25.443-.176v12.569l-.443-.178-.625-.25-.603.301-1.444.723-2.41-.804-.475-.158-.474.158-2.41.803-1.445-.722-.603-.3-.625.25-.443.177V6.215l.443.178.625.25.603-.301 1.444-.722 2.41.803.475.158.474-.158 2.41-.803 1.445.722zM20 4l-1.5.6-1 .4-2-1-3 1-3-1-2 1-1-.4L5 4v17l1.5-.6 1-.4 2 1 3-1 3 1 2-1 1 .4 1.5.6V4zm-3.5 6.25v-1.5h-8v1.5h8zm0 3v-1.5h-8v1.5h8zm-8 3v-1.5h8v1.5h-8z",
      clipRule: "evenodd"
    }))
  },
  edit: _edit__WEBPACK_IMPORTED_MODULE_1__["default"],
  save: _save__WEBPACK_IMPORTED_MODULE_2__.save
});
/******/ })()
;
//# sourceMappingURL=course-curriculum.js.map