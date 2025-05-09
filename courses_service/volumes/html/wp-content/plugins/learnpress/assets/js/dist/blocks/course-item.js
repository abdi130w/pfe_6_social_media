/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./assets/src/apps/js/blocks/courses/course-item/edit.js":
/*!***************************************************************!*\
  !*** ./assets/src/apps/js/blocks/courses/course-item/edit.js ***!
  \***************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/block-editor */ "@wordpress/block-editor");
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _wordpress_data__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @wordpress/data */ "@wordpress/data");
/* harmony import */ var _wordpress_data__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_wordpress_data__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @wordpress/element */ "@wordpress/element");
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_wordpress_element__WEBPACK_IMPORTED_MODULE_3__);




function PostTemplateInnerBlocks({
  classList
}) {
  const innerBlocksProps = (0,_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.useInnerBlocksProps)();
  return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    ...innerBlocksProps
  });
}
function PostTemplateBlockPreview({
  blocks,
  blockContextId,
  classList,
  isHidden,
  setActiveBlockContextId
}) {
  const blockPreviewProps = (0,_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.__experimentalUseBlockPreview)({
    blocks
  });
  const handleOnClick = () => {
    setActiveBlockContextId(blockContextId);
  };
  const style = {
    display: isHidden ? 'none' : undefined
  };
  return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("li", {
    ...blockPreviewProps,
    tabIndex: 0
    // eslint-disable-next-line jsx-a11y/no-noninteractive-element-to-interactive-role
    ,
    role: "button",
    onClick: handleOnClick,
    onKeyPress: handleOnClick,
    style: style
  });
}
const MemoizedPostTemplateBlockPreview = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_3__.memo)(PostTemplateBlockPreview);
const Edit = ({
  clientId,
  context
}) => {
  var _context$lpCoursesDat;
  const blockProps = (0,_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.useBlockProps)();
  const [activeBlockContextId, setActiveBlockContextId] = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_3__.useState)();
  const lpCoursesData = (_context$lpCoursesDat = context.lpCoursesData) !== null && _context$lpCoursesDat !== void 0 ? _context$lpCoursesDat : undefined;
  const coursesData = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_3__.useMemo)(() => lpCoursesData ? lpCoursesData.data.courses : [], [lpCoursesData]);
  const {
    blocks
  } = (0,_wordpress_data__WEBPACK_IMPORTED_MODULE_2__.useSelect)(select => {
    const {
      getBlocks
    } = select(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.store);
    return {
      blocks: getBlocks(clientId)
    };
  }, [clientId]);
  const blockContexts = (0,_wordpress_element__WEBPACK_IMPORTED_MODULE_3__.useMemo)(() => lpCoursesData?.data?.courses?.map(post => ({
    lpCourseData: post,
    postId: post.ID,
    postTitle: post.post_title
  })), [lpCoursesData]);
  return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("ul", {
    ...blockProps
  }, blockContexts && blockContexts.map(blockContext => (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.BlockContextProvider, {
    key: blockContext.postId,
    value: blockContext
  }, blockContext.postId === (activeBlockContextId || blockContexts[0]?.postId) ? (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(PostTemplateInnerBlocks, {
    classList: blockContext.classList
  }) : null, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(MemoizedPostTemplateBlockPreview, {
    blocks: blocks,
    blockContextId: blockContext.postId,
    classList: blockContext.classList,
    setActiveBlockContextId: setActiveBlockContextId,
    isHidden: blockContext.postId === (activeBlockContextId || blockContexts[0]?.postId)
  }))));
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (Edit);

/***/ }),

/***/ "./assets/src/apps/js/blocks/courses/course-item/save.js":
/*!***************************************************************!*\
  !*** ./assets/src/apps/js/blocks/courses/course-item/save.js ***!
  \***************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/block-editor */ "@wordpress/block-editor");
/* harmony import */ var _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__);


const Save = props => {
  const blockProps = _wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.useBlockProps.save();
  return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("div", {
    ...blockProps
  }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(_wordpress_block_editor__WEBPACK_IMPORTED_MODULE_1__.InnerBlocks.Content, null));
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (Save);

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

/***/ "@wordpress/data":
/*!******************************!*\
  !*** external ["wp","data"] ***!
  \******************************/
/***/ ((module) => {

module.exports = window["wp"]["data"];

/***/ }),

/***/ "@wordpress/element":
/*!*********************************!*\
  !*** external ["wp","element"] ***!
  \*********************************/
/***/ ((module) => {

module.exports = window["wp"]["element"];

/***/ }),

/***/ "./assets/src/apps/js/blocks/courses/course-item/block.json":
/*!******************************************************************!*\
  !*** ./assets/src/apps/js/blocks/courses/course-item/block.json ***!
  \******************************************************************/
/***/ ((module) => {

module.exports = /*#__PURE__*/JSON.parse('{"$schema":"https://schemas.wp.org/trunk/block.json","apiVersion":3,"name":"learnpress/course-item-template","title":"Course Item Template","category":"","description":"Course Item Template","textdomain":"learnpress","keywords":["course item","learnpress"],"usesContext":["lpCourseQuery","lpCoursesData"],"supports":{"align":true},"ancestor":["learnpress/list-courses"]}');

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
/*!****************************************************************!*\
  !*** ./assets/src/apps/js/blocks/courses/course-item/index.js ***!
  \****************************************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _edit__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./edit */ "./assets/src/apps/js/blocks/courses/course-item/edit.js");
/* harmony import */ var _save__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./save */ "./assets/src/apps/js/blocks/courses/course-item/save.js");
/* harmony import */ var _block_json__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./block.json */ "./assets/src/apps/js/blocks/courses/course-item/block.json");
/* harmony import */ var _wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @wordpress/blocks */ "@wordpress/blocks");
/* harmony import */ var _wordpress_blocks__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__);

/**
 * Register block single course property.
 */




(0,_wordpress_blocks__WEBPACK_IMPORTED_MODULE_4__.registerBlockType)('learnpress/course-item', {
  ..._block_json__WEBPACK_IMPORTED_MODULE_3__,
  icon: {
    src: (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("svg", {
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      width: "24",
      height: "24",
      "aria-hidden": "true",
      focusable: "false"
    }, (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)("path", {
      fillRule: "evenodd",
      d: "M5 5.5h14a.5.5 0 01.5.5v1.5a.5.5 0 01-.5.5H5a.5.5 0 01-.5-.5V6a.5.5 0 01.5-.5zM4 9.232A2 2 0 013 7.5V6a2 2 0 012-2h14a2 2 0 012 2v1.5a2 2 0 01-1 1.732V18a2 2 0 01-2 2H6a2 2 0 01-2-2V9.232zm1.5.268V18a.5.5 0 00.5.5h12a.5.5 0 00.5-.5V9.5h-13z",
      clipRule: "evenodd"
    }))
  },
  edit: _edit__WEBPACK_IMPORTED_MODULE_1__["default"],
  save: _save__WEBPACK_IMPORTED_MODULE_2__["default"]
});
/******/ })()
;
//# sourceMappingURL=course-item.js.map