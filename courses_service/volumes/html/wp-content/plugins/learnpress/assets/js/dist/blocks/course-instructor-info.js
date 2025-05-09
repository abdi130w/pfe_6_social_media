/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./assets/src/apps/js/blocks/course-elements/course-instructor-info/edit.js":
/*!**********************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-instructor-info/edit.js ***!
  \**********************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   edit: () => (/* binding */ edit)
/* harmony export */ });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/i18n */ "@wordpress/i18n");
/* harmony import */ var _wordpress_i18n__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @wordpress/block-editor */ "@wordpress/block-editor");
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2__);



const edit = props => {
  const blockProps = (0,_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_2__.useBlockProps)();
  return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(react__WEBPACK_IMPORTED_MODULE_0__.Fragment, null, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    ...blockProps
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "lp-section-instructor"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("h3", {
    className: "section-title"
  }, 'Instructor'), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "lp-instructor-info"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "instructor-avatar"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("img", {
    src: "https://placehold.co/160x160?text=Instructor"
  })), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "lp-section-instructor"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "instructor-display-name"
  }, (0,_wordpress_i18n__WEBPACK_IMPORTED_MODULE_1__.__)('Instructor Name', 'learnpress')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "lp-instructor-meta"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "instructor-item-meta"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "instructor-total-students"
  }, '2 Students')), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "instructor-item-meta"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("span", {
    className: "instructor-total-courses"
  }, '12 Courses'))), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    className: "instructor-description"
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("p", null, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua')))))));
};

/***/ }),

/***/ "./assets/src/apps/js/blocks/course-elements/course-instructor-info/save.js":
/*!**********************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-instructor-info/save.js ***!
  \**********************************************************************************/
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

/***/ "./assets/src/apps/js/blocks/course-elements/course-instructor-info/block.json":
/*!*************************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-instructor-info/block.json ***!
  \*************************************************************************************/
/***/ ((module) => {

module.exports = /*#__PURE__*/JSON.parse('{"$schema":"https://schemas.wp.org/trunk/block.json","apiVersion":3,"name":"learnpress/course-instructor-info","title":"Course Instructor Info","category":"learnpress-course-elements","icon":"index-card","description":"Renders template Instructor Section PHP templates.","textdomain":"learnpress","keywords":["instructor info single course","learnpress"],"usesContext":[],"supports":{"multiple":false,"align":["wide","full"],"html":false,"typography":{"fontSize":true,"lineHeight":false,"fontWeight":true,"__experimentalFontFamily":false,"__experimentalTextDecoration":false,"__experimentalFontStyle":false,"__experimentalFontWeight":true,"__experimentalLetterSpacing":false,"__experimentalTextTransform":true,"__experimentalDefaultControls":{"fontSize":true}},"color":{"background":false,"text":true,"link":false,"heading":true,"gradients":false,"__experimentalDefaultControls":{"text":true,"h3":true}},"spacing":{"padding":true,"margin":true,"__experimentalDefaultControls":{"margin":false,"padding":false}}}}');

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
/*!***********************************************************************************!*\
  !*** ./assets/src/apps/js/blocks/course-elements/course-instructor-info/index.js ***!
  \***********************************************************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _edit__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./edit */ "./assets/src/apps/js/blocks/course-elements/course-instructor-info/edit.js");
/* harmony import */ var _save__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./save */ "./assets/src/apps/js/blocks/course-elements/course-instructor-info/save.js");
/* harmony import */ var _block_json__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./block.json */ "./assets/src/apps/js/blocks/course-elements/course-instructor-info/block.json");
/* harmony import */ var _wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @wordpress/blocks */ "@wordpress/blocks");
/* harmony import */ var _wordpress_blocks__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__);

/**
 * Register block course instructor info.
 */




(0,_wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__.registerBlockType)('learnpress/course-instructor-info', {
  ..._block_json__WEBPACK_IMPORTED_MODULE_3__,
  icon: {
    src: (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("svg", {
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      xmlns: "http://www.w3.org/2000/svg"
    }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("path", {
      fillRule: "evenodd",
      clipRule: "evenodd",
      d: "M19 11H5C4.72386 11 4.5 11.2239 4.5 11.5V17.5C4.5 17.7761 4.72386 18 5 18H19C19.2761 18 19.5 17.7761 19.5 17.5V11.5C19.5 11.2239 19.2761 11 19 11ZM5 9.5H19C20.1046 9.5 21 10.3954 21 11.5V17.5C21 18.6046 20.1046 19.5 19 19.5H5C3.89543 19.5 3 18.6046 3 17.5V11.5C3 10.3954 3.89543 9.5 5 9.5Z",
      fill: "currentColor"
    }), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("path", {
      fillRule: "evenodd",
      clipRule: "evenodd",
      d: "M18 7.5C18 7.77614 17.7761 8 17.5 8L6.5 8C6.22386 8 6 7.77614 6 7.5V7.5C6 7.22386 6.22386 7 6.5 7L17.5 7C17.7761 7 18 7.22386 18 7.5V7.5Z",
      fill: "currentColor"
    }), (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("path", {
      fillRule: "evenodd",
      clipRule: "evenodd",
      d: "M16 5C16 5.27614 15.7761 5.5 15.5 5.5L8.5 5.5C8.22386 5.5 8 5.27614 8 5V5C8 4.72386 8.22386 4.5 8.5 4.5L15.5 4.5C15.7761 4.5 16 4.72386 16 5V5Z",
      fill: "currentColor"
    }))
  },
  edit: _edit__WEBPACK_IMPORTED_MODULE_1__.edit,
  save: _save__WEBPACK_IMPORTED_MODULE_2__.save
});
/******/ })()
;
//# sourceMappingURL=course-instructor-info.js.map