/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./assets/src/apps/js/frontend/material.js":
/*!*************************************************!*\
  !*** ./assets/src/apps/js/frontend/material.js ***!
  \*************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (/* binding */ lpMaterialsLoad)
/* harmony export */ });
/* harmony import */ var _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @wordpress/api-fetch */ "@wordpress/api-fetch");
/* harmony import */ var _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_0__);

function lpMaterialsLoad() {
  // console.log('loaded');
  const Sekeleton = () => {
    const elementSkeleton = document.querySelector('.lp-material-skeleton');
    if (!elementSkeleton) {
      return;
    }
    const loadMoreBtn = elementSkeleton.querySelector('.lp-loadmore-material');
    elementSkeleton.querySelector('.course-material-table').style.display = 'none';
    loadMoreBtn.style.display = 'none';
    getResponse(elementSkeleton);
  };
  const getResponse = async (ele, page = 1) => {
    const course_id = parseInt(ele.dataset.courseId),
      item_id = parseInt(ele.dataset.itemId);
    const elListMaterial = ele.closest('.lp-list-material');
    const elementMaterial = ele.querySelector('.course-material-table');
    const loadMoreBtn = document.querySelector('.lp-loadmore-material');
    const elListItems = document.querySelector('.lp-list-material');
    const elSkeleton = ele.querySelector('.lp-skeleton-animation');
    try {
      const response = await _wordpress_api_fetch__WEBPACK_IMPORTED_MODULE_0___default()({
        path: `lp/v1/material/by-item`,
        data: {
          course_id,
          item_id,
          page
        },
        method: 'POST'
      });
      const {
        data,
        status,
        message
      } = response;
      if (elSkeleton) {
        elSkeleton.remove();
      }
      if (status !== 'success') {
        elListMaterial.insertAdjacentHTML('beforeend', message);
        return;
      }
      if (data.items && data.items.length > 0) {
        elementMaterial.style.display = 'table';
        elementMaterial.querySelector('tbody').insertAdjacentHTML('beforeend', data.items);
      } else {
        elListItems.innerHTML = message;
      }
      if (data.load_more) {
        loadMoreBtn.style.display = 'inline-block';
        loadMoreBtn.setAttribute('page', page + 1);
        if (loadMoreBtn.classList.contains('loading')) {
          loadMoreBtn.classList.remove('loading');
        }
      } else {
        loadMoreBtn.style.display = 'none';
      }
    } catch (error) {
      console.log(error.message);
    }
  };
  Sekeleton();
  document.addEventListener('click', function (e) {
    const target = e.target;
    if (target.classList.contains('lp-loadmore-material')) {
      const elementSkeleton = document.querySelector('.lp-material-skeleton');
      const page = parseInt(target.getAttribute('page'));
      target.classList.add('loading');
      getResponse(elementSkeleton, page);
      // target.classList.remove( 'loading' );
    }
  });
}

/***/ }),

/***/ "./assets/src/apps/js/frontend/show-lp-overlay-complete-item.js":
/*!**********************************************************************!*\
  !*** ./assets/src/apps/js/frontend/show-lp-overlay-complete-item.js ***!
  \**********************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../utils/lp-modal-overlay */ "./assets/src/apps/js/utils/lp-modal-overlay.js");

const lpModalOverlayCompleteItem = {
  elBtnFinishCourse: null,
  elBtnCompleteItem: null,
  init() {
    if (!_utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].init()) {
      return;
    }
    if (undefined === lpGlobalSettings || 'yes' !== lpGlobalSettings.option_enable_popup_confirm_finish) {
      return;
    }
    this.elBtnFinishCourse = document.querySelectorAll('.lp-btn-finish-course');
    this.elBtnCompleteItem = document.querySelector('.lp-btn-complete-item');
    if (this.elBtnCompleteItem) {
      this.elBtnCompleteItem.addEventListener('click', e => {
        e.preventDefault();
        const form = e.target.closest('form');
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].elLPOverlay.show();
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].setTitleModal(form.dataset.title);
        // ESC html
        const div = document.createElement('div');
        div.appendChild(document.createTextNode(form.dataset.confirm));
        const contentModal = div.innerHTML;
        // End ESC html
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].setContentModal('<div class="pd-2em">' + contentModal + '</div>');
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].callBackYes = () => {
          form.submit();
        };
      });
    }
    if (this.elBtnFinishCourse) {
      this.elBtnFinishCourse.forEach(element => element.addEventListener('click', e => {
        e.preventDefault();
        const form = e.target.closest('form');
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].elLPOverlay.show();
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].setTitleModal(form.dataset.title);
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].setContentModal('<div class="pd-2em">' + form.dataset.confirm + '</div>');
        _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__["default"].callBackYes = () => {
          form.submit();
        };
      }));
    }
  }
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (lpModalOverlayCompleteItem);

/***/ }),

/***/ "./assets/src/apps/js/frontend/single-course/index.js":
/*!************************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-course/index.js ***!
  \************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @wordpress/element */ "@wordpress/element");
/* harmony import */ var _wordpress_element__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_wordpress_element__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _learnpress_quiz__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @learnpress/quiz */ "@learnpress/quiz");
/* harmony import */ var _learnpress_quiz__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_learnpress_quiz__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _store__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./store */ "./assets/src/apps/js/frontend/single-course/store/index.js");
/* harmony import */ var _store__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_store__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _single_curriculum_components_sidebar__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../single-curriculum/components/sidebar */ "./assets/src/apps/js/frontend/single-curriculum/components/sidebar.js");




 // Use toggle in Curriculum tab.

class SingleCourse extends _wordpress_element__WEBPACK_IMPORTED_MODULE_1__.Component {
  render() {
    return (0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(react__WEBPACK_IMPORTED_MODULE_0__.Fragment, null);
  }
}
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (SingleCourse);
function run() {
  (0,_single_curriculum_components_sidebar__WEBPACK_IMPORTED_MODULE_4__.Sidebar)();
}
document.addEventListener('DOMContentLoaded', () => {
  run();
});

/***/ }),

/***/ "./assets/src/apps/js/frontend/single-course/store/index.js":
/*!******************************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-course/store/index.js ***!
  \******************************************************************/
/***/ (() => {

/**
 * Created by tu on 9/19/19.
 */

/***/ }),

/***/ "./assets/src/apps/js/frontend/single-curriculum/components/search.js":
/*!****************************************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-curriculum/components/search.js ***!
  \****************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   searchCourseContent: () => (/* binding */ searchCourseContent)
/* harmony export */ });
const searchCourseContent = () => {
  const popup = document.querySelector('#popup-course');
  const list = document.querySelector('#learn-press-course-curriculum');
  if (popup && list) {
    const items = list.querySelector('.curriculum-sections');
    const form = popup.querySelector('.search-course');
    const search = popup.querySelector('.search-course input[type="text"]');
    if (!search || !items || !form) {
      return;
    }
    const sections = items.querySelectorAll('li.section');
    const dataItems = items.querySelectorAll('li.course-item');
    const dataSearch = [];
    dataItems.forEach(item => {
      const itemID = item.dataset.id;
      const name = item.querySelector('.item-name');
      dataSearch.push({
        id: itemID,
        name: name ? name.textContent.toLowerCase() : ''
      });
    });
    const submit = event => {
      event.preventDefault();
      const inputVal = search.value;
      form.classList.add('searching');
      if (!inputVal) {
        form.classList.remove('searching');
      }
      const outputs = [];
      dataSearch.forEach(i => {
        if (!inputVal || i.name.match(inputVal.toLowerCase())) {
          outputs.push(i.id);
          dataItems.forEach(c => {
            if (outputs.indexOf(c.dataset.id) !== -1) {
              c.classList.remove('hide-if-js');
            } else {
              c.classList.add('hide-if-js');
            }
          });
        }
      });
      sections.forEach(section => {
        const listItem = section.querySelectorAll('.course-item');
        const isTrue = [];
        listItem.forEach(a => {
          if (outputs.includes(a.dataset.id)) {
            isTrue.push(a.dataset.id);
          }
        });
        if (isTrue.length === 0) {
          section.classList.add('hide-if-js');
        } else {
          section.classList.remove('hide-if-js');
        }
      });
    };
    const clear = form.querySelector('.clear');
    if (clear) {
      clear.addEventListener('click', e => {
        e.preventDefault();
        search.value = '';
        submit(e);
      });
    }
    form.addEventListener('submit', submit);
    search.addEventListener('keyup', submit);
  }
};

/***/ }),

/***/ "./assets/src/apps/js/frontend/single-curriculum/components/sidebar.js":
/*!*****************************************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-curriculum/components/sidebar.js ***!
  \*****************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   Sidebar: () => (/* binding */ Sidebar)
/* harmony export */ });
const $ = jQuery;
const {
  throttle
} = lodash;
const Sidebar = () => {
  // Tungnx - Show/hide sidebar curriculumn
  const elSidebarToggle = document.querySelector('#sidebar-toggle');

  // For style of theme
  const toggleSidebar = toggle => {
    $('body').removeClass('lp-sidebar-toggle__open');
    $('body').removeClass('lp-sidebar-toggle__close');
    if (toggle) {
      $('body').addClass('lp-sidebar-toggle__close');
    } else {
      $('body').addClass('lp-sidebar-toggle__open');
    }
  };

  // For lp and theme
  if (elSidebarToggle) {
    if ($(window).innerWidth() <= 768) {
      elSidebarToggle.setAttribute('checked', 'checked');
    } else if (LP.Cookies.get('sidebar-toggle')) {
      elSidebarToggle.setAttribute('checked', 'checked');
    } else {
      elSidebarToggle.removeAttribute('checked');
    }
    document.querySelector('#popup-course').addEventListener('click', e => {
      if (e.target.id === 'sidebar-toggle') {
        LP.Cookies.set('sidebar-toggle', e.target.checked ? true : false);
        toggleSidebar(LP.Cookies.get('sidebar-toggle'));
      }
    });
  }
  // End editor by tungnx

  const $curriculum = $('#learn-press-course-curriculum');
  $curriculum.find('.section-desc').each((i, el) => {
    const a = $('<span class="show-desc"></span>').on('click', () => {
      b.toggleClass('c');
    });
    const b = $(el).siblings('.section-title').append(a);
  });
  $('.section').each(function () {
    const $section = $(this),
      $toggle = $section.find('.section-left');
    $toggle.on('click', function () {
      const isClose = $section.toggleClass('closed').hasClass('closed');
      const sections = LP.Cookies.get('closed-section-' + lpGlobalSettings.post_id) || [];
      const sectionId = parseInt($section.data('section-id'));
      const at = sections.findIndex(id => {
        return id == sectionId;
      });
      if (isClose) {
        sections.push(parseInt($section.data('section-id')));
      } else {
        sections.splice(at, 1);
      }
      LP.Cookies.remove('closed-section-(.*)');
      LP.Cookies.set('closed-section-' + lpGlobalSettings.post_id, [...new Set(sections)]);
    });
  });
};

/***/ }),

/***/ "./assets/src/apps/js/frontend/single-curriculum/scrolltoitem.js":
/*!***********************************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-curriculum/scrolltoitem.js ***!
  \***********************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../utils/lp-modal-overlay */ "./assets/src/apps/js/utils/lp-modal-overlay.js");

const $ = jQuery;
const scrollToItemCurrent = {
  init() {
    this.scrollToItemViewing = function () {
      const elItemViewing = $('.viewing-course-item');
      if (elItemViewing.length) {
        const elCourseCurriculumn = $('#learn-press-course-curriculum');
        const heightCourseItemContentHeader = $('#popup-sidebar').outerHeight();
        const heightSectionTitle = $('.section-title').outerHeight();
        const heightSectionHeader = $('.section-header').outerHeight();
        const regex = new RegExp('^viewing-course-item-([0-9].*)');
        const classList = elItemViewing.attr('class');
        const classArr = classList.split(/\s+/);
        let idItem = 0;
        $.each(classArr, function (i, className) {
          const compare = regex.exec(className);
          if (compare) {
            idItem = compare[1];
            return false;
          }
        });
        if (0 === idItem) {
          return;
        }
        const elItemCurrent = $('.course-item-' + idItem);
        elItemCurrent.addClass('current');
        const offSetTop = elItemCurrent.offset().top;
        const offset = elItemCurrent.offset().top - elCourseCurriculumn.offset().top + elCourseCurriculumn.scrollTop();
        elCourseCurriculumn.animate({
          scrollTop: LP.Hook.applyFilters('scroll-item-current', offset - heightSectionHeader)
        }, 800);
      }
    };
    this.scrollToItemViewing();
  }
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (scrollToItemCurrent);

/***/ }),

/***/ "./assets/src/apps/js/frontend/single-curriculum/skeleton.js":
/*!*******************************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-curriculum/skeleton.js ***!
  \*******************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (/* binding */ courseCurriculumSkeleton)
/* harmony export */ });
/* harmony import */ var _wordpress_url__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @wordpress/url */ "@wordpress/url");
/* harmony import */ var _wordpress_url__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_wordpress_url__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _scrolltoitem__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./scrolltoitem */ "./assets/src/apps/js/frontend/single-curriculum/scrolltoitem.js");
/* harmony import */ var _components_search__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./components/search */ "./assets/src/apps/js/frontend/single-curriculum/components/search.js");
// Rest API load content in Tab Curriculum - Nhamdv.

//import apiFetch from '@wordpress/api-fetch';


function courseCurriculumSkeleton(courseID = '') {
  let idItemViewing = 0;
  const elItemViewing = document.querySelector('.viewing-course-item');
  if (elItemViewing) {
    const regex = new RegExp('^viewing-course-item-([0-9].*)');
    const classList = elItemViewing.classList;
    classList.forEach(function (className) {
      const compare = regex.exec(className);
      if (compare) {
        idItemViewing = compare[1];
        return false;
      }
    });
  }
  let isLoadingItems = false;
  let isLoadingSections = false;
  const Sekeleton = () => {
    const elementCurriculum = document.querySelector('.learnpress-course-curriculum');
    if (!elementCurriculum) {
      return;
    }
    getResponse(elementCurriculum);
  };
  const getResponse = async ele => {
    const skeleton = ele.querySelector('.lp-skeleton-animation');
    const itemID = ele.dataset.id;
    const sectionID = ele.dataset.section;
    try {
      const page = 1;
      let url = lpData.lp_rest_url + 'lp/v1/lazy-load/course-curriculum/';
      url = (0,_wordpress_url__WEBPACK_IMPORTED_MODULE_0__.addQueryArgs)(url, {
        courseId: courseID || lpGlobalSettings.post_id || '',
        page,
        sectionID: sectionID || '',
        idItemViewing
      });
      let paramsFetch = {};
      if (0 !== parseInt(lpData.user_id)) {
        paramsFetch = {
          headers: {
            'X-WP-Nonce': lpData.nonce
          }
        };
      }
      let response = await fetch(url, {
        method: 'GET',
        ...paramsFetch
      });
      response = await response.json();
      const {
        data,
        status,
        message
      } = response;
      const section_ids = data.section_ids;
      if (status === 'error') {
        throw new Error(message || 'Error');
      }
      const returnData = data.content;
      if (sectionID) {
        if (section_ids && !section_ids.includes(sectionID)) {
          const response2 = await getResponsive('', page + 1, sectionID);
          if (response2) {
            const {
              data2,
              pages2,
              page2
            } = response2;
            await parseContentItems({
              ele,
              returnData,
              sectionID,
              itemID,
              data2,
              pages2,
              page2
            });
          }
        } else {
          await parseContentItems({
            ele,
            returnData,
            sectionID,
            itemID
          });
        }
      } else {
        returnData && ele.insertAdjacentHTML('beforeend', returnData);
      }
    } catch (error) {
      ele.insertAdjacentHTML('beforeend', `<div class="lp-ajax-message error" style="display:block">${error.message || 'Error: Query lp/v1/lazy-load/course-curriculum'}</div>`);
    }
    skeleton && skeleton.remove();
    (0,_components_search__WEBPACK_IMPORTED_MODULE_2__.searchCourseContent)();
  };
  const parseContentItems = async ({
    ele,
    returnData,
    sectionID,
    itemID,
    data2,
    pages2,
    page2
  }) => {
    const parser = new DOMParser();
    const doc = parser.parseFromString(returnData, 'text/html');
    if (data2) {
      const sections = doc.querySelector('.curriculum-sections');
      const loadMoreBtn = doc.querySelector('.curriculum-more__button');
      if (loadMoreBtn) {
        if (pages2 <= page2) {
          loadMoreBtn.remove();
        } else {
          loadMoreBtn.dataset.page = page2;
        }
      }
      sections.insertAdjacentHTML('beforeend', data2);
    }
    const section = doc.querySelector(`[data-section-id="${sectionID}"]`);
    if (section) {
      const items = section.querySelectorAll('.course-item');
      const item_ids = [...items].map(item => item.dataset.id);
      const sectionContent = section.querySelector('.section-content');
      const itemLoadMore = section.querySelector('.section-item__loadmore');
      if (itemID && !item_ids.includes(itemID)) {
        const responseItem = await getResponsiveItem('', 2, sectionID, itemID);
        const {
          data3,
          pages3,
          paged3,
          page
        } = responseItem;
        if (pages3 <= paged3 || pages3 <= page) {
          itemLoadMore.remove();
        } else {
          itemLoadMore.dataset.page = page;
        }
        if (data3 && sectionContent) {
          sectionContent.insertAdjacentHTML('beforeend', data3);
        }
      }
    }
    ele.insertAdjacentHTML('beforeend', doc.body.innerHTML);
    _scrolltoitem__WEBPACK_IMPORTED_MODULE_1__["default"].init();
  };
  const getResponsiveItem = async (returnData, paged, sectionID, itemID) => {
    let url = lpData.lp_rest_url + 'lp/v1/lazy-load/course-curriculum-items/';
    url = (0,_wordpress_url__WEBPACK_IMPORTED_MODULE_0__.addQueryArgs)(url, {
      sectionId: sectionID || '',
      page: paged
    });
    let paramsFetch = {};
    if (0 !== parseInt(lpData.user_id)) {
      paramsFetch = {
        headers: {
          'X-WP-Nonce': lpData.nonce
        }
      };
    }
    let response = await fetch(url, {
      method: 'GET',
      ...paramsFetch
    });
    response = await response.json();
    const {
      data,
      status,
      pages,
      message
    } = response;
    const {
      page
    } = data;
    let item_ids;
    if (status === 'success') {
      const dataTmp = data.content;
      item_ids = data.item_ids;
      returnData += dataTmp;
      if (sectionID && item_ids && itemID && !item_ids.includes(itemID)) {
        return getResponsiveItem(returnData, paged + 1, sectionID, itemID);
      }
    }
    isLoadingItems = false;
    return {
      data3: returnData,
      pages3: pages || data.pages,
      status3: status,
      message3: message,
      page: page || 0
    };
  };
  const getResponsive = async (returnData, page, sectionID) => {
    let url = lpData.lp_rest_url + 'lp/v1/lazy-load/course-curriculum/';
    url = (0,_wordpress_url__WEBPACK_IMPORTED_MODULE_0__.addQueryArgs)(url, {
      courseId: courseID || lpGlobalSettings.post_id || '',
      page,
      sectionID: sectionID || '',
      loadMore: true
    });
    let paramsFetch = {};
    if (0 !== parseInt(lpData.user_id)) {
      paramsFetch = {
        headers: {
          'X-WP-Nonce': lpData.nonce
        }
      };
    }
    let response = await fetch(url, {
      method: 'GET',
      ...paramsFetch
    });
    response = await response.json();
    const {
      data,
      status,
      message
    } = response;
    const returnDataTmp = data.content;
    const section_ids = data.section_ids;
    const pages = data.pages;
    if (status === 'success') {
      returnData += returnDataTmp;
      if (sectionID && section_ids && section_ids.length > 0 && !section_ids.includes(sectionID)) {
        return getResponsive(returnData, page + 1, sectionID);
      }
    }
    isLoadingSections = false;
    return {
      data2: returnData,
      pages2: pages || data.pages,
      page2: page,
      status2: status,
      message2: message
    };
  };
  Sekeleton();
  document.addEventListener('click', e => {
    const sectionBtns = document.querySelectorAll('.section-item__loadmore');
    [...sectionBtns].map(async sectionBtn => {
      if (sectionBtn.contains(e.target) && !isLoadingItems) {
        isLoadingItems = true;
        const sectionItem = sectionBtn.parentNode;
        const sectionId = sectionItem.getAttribute('data-section-id');
        const sectionContent = sectionItem.querySelector('.section-content');
        const paged = parseInt(sectionBtn.dataset.page);
        sectionBtn.classList.add('loading');
        try {
          const response = await getResponsiveItem('', paged + 1, sectionId, '');
          const {
            data3,
            pages3,
            status3,
            message3
          } = response;
          if (status3 === 'error') {
            throw new Error(message3 || 'Error');
          }
          if (pages3 <= paged + 1) {
            sectionBtn.remove();
          } else {
            sectionBtn.dataset.page = paged + 1;
          }
          sectionContent.insertAdjacentHTML('beforeend', data3);
        } catch (e) {
          sectionContent.insertAdjacentHTML('beforeend', `<div class="lp-ajax-message error" style="display:block">${e.message || 'Error: Query lp/v1/lazy-load/course-curriculum'}</div>`);
        }
        sectionBtn.classList.remove('loading');
        (0,_components_search__WEBPACK_IMPORTED_MODULE_2__.searchCourseContent)();
      }
    });

    // Load more Sections
    const moreSections = document.querySelectorAll('.curriculum-more__button');
    [...moreSections].map(async moreSection => {
      if (moreSection.contains(e.target) && !isLoadingSections) {
        isLoadingSections = true;
        const paged = parseInt(moreSection.dataset.page);
        const sections = moreSection.parentNode.parentNode.querySelector('.curriculum-sections');
        if (paged && sections) {
          moreSection.classList.add('loading');
          try {
            const response2 = await getResponsive('', paged + 1, '');
            const {
              data2,
              pages2,
              status2,
              message2
            } = response2;
            if (status2 === 'error') {
              throw new Error(message2 || 'Error');
            }
            if (pages2 <= paged + 1) {
              moreSection.remove();
            } else {
              moreSection.dataset.page = paged + 1;
            }
            sections.insertAdjacentHTML('beforeend', data2);
          } catch (e) {
            sections.insertAdjacentHTML('beforeend', `<div class="lp-ajax-message error" style="display:block">${e.message || 'Error: Query lp/v1/lazy-load/course-curriculum'}</div>`);
          }
          moreSection.classList.remove('loading');
          (0,_components_search__WEBPACK_IMPORTED_MODULE_2__.searchCourseContent)();
        }
      }
    });

    // Show/Hide accordion
    if (document.querySelector('.learnpress-course-curriculum')) {
      const sections = document.querySelectorAll('.section');
      [...sections].map(section => {
        if (section.contains(e.target)) {
          const toggle = section.querySelector('.section-left');
          toggle.contains(e.target) && section.classList.toggle('closed');
        }
      });
    }
  });
}

/***/ }),

/***/ "./assets/src/apps/js/frontend/tabs-scroll.js":
/*!****************************************************!*\
  !*** ./assets/src/apps/js/frontend/tabs-scroll.js ***!
  \****************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (/* binding */ TabsDragScroll)
/* harmony export */ });
function TabsDragScroll() {
  // Selectors and DOM elements
  const TabsDragScroll = document.querySelector('.TabsDragScroll');
  if (!TabsDragScroll) return;
  const tabMenu = TabsDragScroll.querySelector('ul');

  // Dragging functionality
  let activeDrag = false;
  tabMenu.addEventListener('mousemove', event => {
    if (!activeDrag) return;
    tabMenu.scrollLeft -= event.movementX;
    // iconVisibility();
    tabMenu.classList.add('dragging');
  });
  document.addEventListener('mouseup', () => {
    activeDrag = false;
    tabMenu.classList.remove('dragging');
  });
  tabMenu.addEventListener('mousedown', () => {
    activeDrag = true;
  });

  // Scroll to <li> on click
  const scrollToLi = li => {
    const liLeft = li.offsetLeft;
    const liWidth = li.offsetWidth;
    const tabCenter = tabMenu.clientWidth / 2 - liWidth / 2;
    tabMenu.scrollTo({
      left: liLeft - tabCenter,
      behavior: 'smooth'
    });
  };

  // Add click event listeners to all <li> elements
  tabMenu.querySelectorAll('li').forEach(li => {
    li.addEventListener('click', () => scrollToLi(li));
  });
}

/***/ }),

/***/ "./assets/src/apps/js/utils/lp-modal-overlay.js":
/*!******************************************************!*\
  !*** ./assets/src/apps/js/utils/lp-modal-overlay.js ***!
  \******************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
const $ = jQuery;
let elLPOverlay = null;
const lpModalOverlay = {
  elLPOverlay: null,
  elMainContent: null,
  elTitle: null,
  elBtnYes: null,
  elBtnNo: null,
  elFooter: null,
  elCalledModal: null,
  callBackYes: null,
  instance: null,
  init() {
    if (this.instance) {
      return true;
    }
    this.elLPOverlay = $('.lp-overlay');
    if (!this.elLPOverlay.length) {
      return false;
    }
    elLPOverlay = this.elLPOverlay;
    this.elMainContent = elLPOverlay.find('.main-content');
    this.elTitle = elLPOverlay.find('.modal-title');
    this.elBtnYes = elLPOverlay.find('.btn-yes');
    this.elBtnNo = elLPOverlay.find('.btn-no');
    this.elFooter = elLPOverlay.find('.lp-modal-footer');
    $(document).on('click', '.close, .btn-no', function () {
      elLPOverlay.hide();
    });
    $(document).on('click', '.btn-yes', function (e) {
      e.preventDefault();
      e.stopPropagation();
      if ('function' === typeof lpModalOverlay.callBackYes) {
        lpModalOverlay.callBackYes(e);
      }
    });
    this.instance = this;
    return true;
  },
  setElCalledModal(elCalledModal) {
    this.elCalledModal = elCalledModal;
  },
  setContentModal(content, event) {
    this.elMainContent.html(content);
    if ('function' === typeof event) {
      event();
    }
  },
  setTitleModal(content) {
    this.elTitle.html(content);
  }
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (lpModalOverlay);

/***/ }),

/***/ "./assets/src/js/frontend/copy-to-clipboard.js":
/*!*****************************************************!*\
  !*** ./assets/src/js/frontend/copy-to-clipboard.js ***!
  \*****************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (/* binding */ CopyToClipboard)
/* harmony export */ });
function LPClick(element, iconBtn, inner) {
  const wrappers = document.querySelectorAll(element);
  if (!wrappers.length) {
    return;
  }
  wrappers.forEach(wrapper => {
    const clickBtn = wrapper.querySelector(iconBtn);
    const class_open = element.replace('.', '') + '__open';
    const closeElement = wrapper.querySelector(element + '__close');
    const isOpenElement = () => wrapper.classList.contains(class_open);
    const showElement = () => {
      if (!isOpenElement()) {
        wrapper.classList.add(class_open);
      }
    };
    const hideElement = () => {
      if (isOpenElement()) {
        wrapper.classList.remove(class_open);
      }
    };
    const toggleElement = () => {
      if (isOpenElement()) {
        hideElement();
      } else {
        showElement();
      }
    };
    const onKeyDown = e => {
      if (e.keyCode === 27) {
        hideElement();
      }
    };
    if (clickBtn) {
      clickBtn.onclick = function (e) {
        e.preventDefault();
        toggleElement();
      };
    }
    document.addEventListener('click', e => {
      if (!isOpenElement()) {
        return;
      }
      const target = e.target;
      if (target.closest(inner) || target.closest(iconBtn)) {
        return;
      }
      hideElement();
    });
    if (closeElement) {
      closeElement.addEventListener('click', e => {
        e.preventDefault();
        hideElement();
      });
    }
    document.addEventListener('keydown', onKeyDown, false);
  });
}
function CopyToClipboard() {
  LPClick('.social-share-toggle', '.share-toggle-icon', '.content-widget-social-share');
  var copyTextareaBtn = document.querySelector('.btn-clipboard');
  if (copyTextareaBtn) {
    copyTextareaBtn.addEventListener('click', function (event) {
      var copyTextarea = document.querySelector('.clipboard-value');
      copyTextarea.focus();
      copyTextarea.select();
      try {
        var successful = document.execCommand('copy');
        var msg = copyTextareaBtn.getAttribute('data-copied');
        copyTextareaBtn.innerHTML = msg + '<span class="tooltip">' + msg + '</span>';
      } catch (err) {}
    });
  }
}

/***/ }),

/***/ "./assets/src/js/utils.js":
/*!********************************!*\
  !*** ./assets/src/js/utils.js ***!
  \********************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
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


/***/ }),

/***/ "./node_modules/css-loader/dist/cjs.js!./node_modules/toastify-js/src/toastify.css":
/*!*****************************************************************************************!*\
  !*** ./node_modules/css-loader/dist/cjs.js!./node_modules/toastify-js/src/toastify.css ***!
  \*****************************************************************************************/
/***/ ((module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var _css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../css-loader/dist/runtime/sourceMaps.js */ "./node_modules/css-loader/dist/runtime/sourceMaps.js");
/* harmony import */ var _css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../css-loader/dist/runtime/api.js */ "./node_modules/css-loader/dist/runtime/api.js");
/* harmony import */ var _css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1__);
// Imports


var ___CSS_LOADER_EXPORT___ = _css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1___default()((_css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0___default()));
// Module
___CSS_LOADER_EXPORT___.push([module.id, `/*!
 * Toastify js 1.12.0
 * https://github.com/apvarun/toastify-js
 * @license MIT licensed
 *
 * Copyright (C) 2018 Varun A P
 */

.toastify {
    padding: 12px 20px;
    color: #ffffff;
    display: inline-block;
    box-shadow: 0 3px 6px -1px rgba(0, 0, 0, 0.12), 0 10px 36px -4px rgba(77, 96, 232, 0.3);
    background: -webkit-linear-gradient(315deg, #73a5ff, #5477f5);
    background: linear-gradient(135deg, #73a5ff, #5477f5);
    position: fixed;
    opacity: 0;
    transition: all 0.4s cubic-bezier(0.215, 0.61, 0.355, 1);
    border-radius: 2px;
    cursor: pointer;
    text-decoration: none;
    max-width: calc(50% - 20px);
    z-index: 2147483647;
}

.toastify.on {
    opacity: 1;
}

.toast-close {
    background: transparent;
    border: 0;
    color: white;
    cursor: pointer;
    font-family: inherit;
    font-size: 1em;
    opacity: 0.4;
    padding: 0 5px;
}

.toastify-right {
    right: 15px;
}

.toastify-left {
    left: 15px;
}

.toastify-top {
    top: -150px;
}

.toastify-bottom {
    bottom: -150px;
}

.toastify-rounded {
    border-radius: 25px;
}

.toastify-avatar {
    width: 1.5em;
    height: 1.5em;
    margin: -7px 5px;
    border-radius: 2px;
}

.toastify-center {
    margin-left: auto;
    margin-right: auto;
    left: 0;
    right: 0;
    max-width: fit-content;
    max-width: -moz-fit-content;
}

@media only screen and (max-width: 360px) {
    .toastify-right, .toastify-left {
        margin-left: auto;
        margin-right: auto;
        left: 0;
        right: 0;
        max-width: fit-content;
    }
}
`, "",{"version":3,"sources":["webpack://./node_modules/toastify-js/src/toastify.css"],"names":[],"mappings":"AAAA;;;;;;EAME;;AAEF;IACI,kBAAkB;IAClB,cAAc;IACd,qBAAqB;IACrB,uFAAuF;IACvF,6DAA6D;IAC7D,qDAAqD;IACrD,eAAe;IACf,UAAU;IACV,wDAAwD;IACxD,kBAAkB;IAClB,eAAe;IACf,qBAAqB;IACrB,2BAA2B;IAC3B,mBAAmB;AACvB;;AAEA;IACI,UAAU;AACd;;AAEA;IACI,uBAAuB;IACvB,SAAS;IACT,YAAY;IACZ,eAAe;IACf,oBAAoB;IACpB,cAAc;IACd,YAAY;IACZ,cAAc;AAClB;;AAEA;IACI,WAAW;AACf;;AAEA;IACI,UAAU;AACd;;AAEA;IACI,WAAW;AACf;;AAEA;IACI,cAAc;AAClB;;AAEA;IACI,mBAAmB;AACvB;;AAEA;IACI,YAAY;IACZ,aAAa;IACb,gBAAgB;IAChB,kBAAkB;AACtB;;AAEA;IACI,iBAAiB;IACjB,kBAAkB;IAClB,OAAO;IACP,QAAQ;IACR,sBAAsB;IACtB,2BAA2B;AAC/B;;AAEA;IACI;QACI,iBAAiB;QACjB,kBAAkB;QAClB,OAAO;QACP,QAAQ;QACR,sBAAsB;IAC1B;AACJ","sourcesContent":["/*!\n * Toastify js 1.12.0\n * https://github.com/apvarun/toastify-js\n * @license MIT licensed\n *\n * Copyright (C) 2018 Varun A P\n */\n\n.toastify {\n    padding: 12px 20px;\n    color: #ffffff;\n    display: inline-block;\n    box-shadow: 0 3px 6px -1px rgba(0, 0, 0, 0.12), 0 10px 36px -4px rgba(77, 96, 232, 0.3);\n    background: -webkit-linear-gradient(315deg, #73a5ff, #5477f5);\n    background: linear-gradient(135deg, #73a5ff, #5477f5);\n    position: fixed;\n    opacity: 0;\n    transition: all 0.4s cubic-bezier(0.215, 0.61, 0.355, 1);\n    border-radius: 2px;\n    cursor: pointer;\n    text-decoration: none;\n    max-width: calc(50% - 20px);\n    z-index: 2147483647;\n}\n\n.toastify.on {\n    opacity: 1;\n}\n\n.toast-close {\n    background: transparent;\n    border: 0;\n    color: white;\n    cursor: pointer;\n    font-family: inherit;\n    font-size: 1em;\n    opacity: 0.4;\n    padding: 0 5px;\n}\n\n.toastify-right {\n    right: 15px;\n}\n\n.toastify-left {\n    left: 15px;\n}\n\n.toastify-top {\n    top: -150px;\n}\n\n.toastify-bottom {\n    bottom: -150px;\n}\n\n.toastify-rounded {\n    border-radius: 25px;\n}\n\n.toastify-avatar {\n    width: 1.5em;\n    height: 1.5em;\n    margin: -7px 5px;\n    border-radius: 2px;\n}\n\n.toastify-center {\n    margin-left: auto;\n    margin-right: auto;\n    left: 0;\n    right: 0;\n    max-width: fit-content;\n    max-width: -moz-fit-content;\n}\n\n@media only screen and (max-width: 360px) {\n    .toastify-right, .toastify-left {\n        margin-left: auto;\n        margin-right: auto;\n        left: 0;\n        right: 0;\n        max-width: fit-content;\n    }\n}\n"],"sourceRoot":""}]);
// Exports
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (___CSS_LOADER_EXPORT___);


/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/api.js":
/*!*****************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/api.js ***!
  \*****************************************************/
/***/ ((module) => {

"use strict";


/*
  MIT License http://www.opensource.org/licenses/mit-license.php
  Author Tobias Koppers @sokra
*/
module.exports = function (cssWithMappingToString) {
  var list = [];

  // return the list of modules as css string
  list.toString = function toString() {
    return this.map(function (item) {
      var content = "";
      var needLayer = typeof item[5] !== "undefined";
      if (item[4]) {
        content += "@supports (".concat(item[4], ") {");
      }
      if (item[2]) {
        content += "@media ".concat(item[2], " {");
      }
      if (needLayer) {
        content += "@layer".concat(item[5].length > 0 ? " ".concat(item[5]) : "", " {");
      }
      content += cssWithMappingToString(item);
      if (needLayer) {
        content += "}";
      }
      if (item[2]) {
        content += "}";
      }
      if (item[4]) {
        content += "}";
      }
      return content;
    }).join("");
  };

  // import a list of modules into the list
  list.i = function i(modules, media, dedupe, supports, layer) {
    if (typeof modules === "string") {
      modules = [[null, modules, undefined]];
    }
    var alreadyImportedModules = {};
    if (dedupe) {
      for (var k = 0; k < this.length; k++) {
        var id = this[k][0];
        if (id != null) {
          alreadyImportedModules[id] = true;
        }
      }
    }
    for (var _k = 0; _k < modules.length; _k++) {
      var item = [].concat(modules[_k]);
      if (dedupe && alreadyImportedModules[item[0]]) {
        continue;
      }
      if (typeof layer !== "undefined") {
        if (typeof item[5] === "undefined") {
          item[5] = layer;
        } else {
          item[1] = "@layer".concat(item[5].length > 0 ? " ".concat(item[5]) : "", " {").concat(item[1], "}");
          item[5] = layer;
        }
      }
      if (media) {
        if (!item[2]) {
          item[2] = media;
        } else {
          item[1] = "@media ".concat(item[2], " {").concat(item[1], "}");
          item[2] = media;
        }
      }
      if (supports) {
        if (!item[4]) {
          item[4] = "".concat(supports);
        } else {
          item[1] = "@supports (".concat(item[4], ") {").concat(item[1], "}");
          item[4] = supports;
        }
      }
      list.push(item);
    }
  };
  return list;
};

/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/sourceMaps.js":
/*!************************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/sourceMaps.js ***!
  \************************************************************/
/***/ ((module) => {

"use strict";


module.exports = function (item) {
  var content = item[1];
  var cssMapping = item[3];
  if (!cssMapping) {
    return content;
  }
  if (typeof btoa === "function") {
    var base64 = btoa(unescape(encodeURIComponent(JSON.stringify(cssMapping))));
    var data = "sourceMappingURL=data:application/json;charset=utf-8;base64,".concat(base64);
    var sourceMapping = "/*# ".concat(data, " */");
    return [content].concat([sourceMapping]).join("\n");
  }
  return [content].join("\n");
};

/***/ }),

/***/ "./node_modules/toastify-js/src/toastify.css":
/*!***************************************************!*\
  !*** ./node_modules/toastify-js/src/toastify.css ***!
  \***************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var _style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! !../../style-loader/dist/runtime/injectStylesIntoStyleTag.js */ "./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js");
/* harmony import */ var _style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! !../../style-loader/dist/runtime/styleDomAPI.js */ "./node_modules/style-loader/dist/runtime/styleDomAPI.js");
/* harmony import */ var _style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! !../../style-loader/dist/runtime/insertBySelector.js */ "./node_modules/style-loader/dist/runtime/insertBySelector.js");
/* harmony import */ var _style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! !../../style-loader/dist/runtime/setAttributesWithoutAttributes.js */ "./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js");
/* harmony import */ var _style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! !../../style-loader/dist/runtime/insertStyleElement.js */ "./node_modules/style-loader/dist/runtime/insertStyleElement.js");
/* harmony import */ var _style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4__);
/* harmony import */ var _style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! !../../style-loader/dist/runtime/styleTagTransform.js */ "./node_modules/style-loader/dist/runtime/styleTagTransform.js");
/* harmony import */ var _style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5___default = /*#__PURE__*/__webpack_require__.n(_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5__);
/* harmony import */ var _css_loader_dist_cjs_js_toastify_css__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! !!../../css-loader/dist/cjs.js!./toastify.css */ "./node_modules/css-loader/dist/cjs.js!./node_modules/toastify-js/src/toastify.css");

      
      
      
      
      
      
      
      
      

var options = {};

options.styleTagTransform = (_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5___default());
options.setAttributes = (_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3___default());

      options.insert = _style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2___default().bind(null, "head");
    
options.domAPI = (_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1___default());
options.insertStyleElement = (_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4___default());

var update = _style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0___default()(_css_loader_dist_cjs_js_toastify_css__WEBPACK_IMPORTED_MODULE_6__["default"], options);




       /* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (_css_loader_dist_cjs_js_toastify_css__WEBPACK_IMPORTED_MODULE_6__["default"] && _css_loader_dist_cjs_js_toastify_css__WEBPACK_IMPORTED_MODULE_6__["default"].locals ? _css_loader_dist_cjs_js_toastify_css__WEBPACK_IMPORTED_MODULE_6__["default"].locals : undefined);


/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js":
/*!****************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js ***!
  \****************************************************************************/
/***/ ((module) => {

"use strict";


var stylesInDOM = [];
function getIndexByIdentifier(identifier) {
  var result = -1;
  for (var i = 0; i < stylesInDOM.length; i++) {
    if (stylesInDOM[i].identifier === identifier) {
      result = i;
      break;
    }
  }
  return result;
}
function modulesToDom(list, options) {
  var idCountMap = {};
  var identifiers = [];
  for (var i = 0; i < list.length; i++) {
    var item = list[i];
    var id = options.base ? item[0] + options.base : item[0];
    var count = idCountMap[id] || 0;
    var identifier = "".concat(id, " ").concat(count);
    idCountMap[id] = count + 1;
    var indexByIdentifier = getIndexByIdentifier(identifier);
    var obj = {
      css: item[1],
      media: item[2],
      sourceMap: item[3],
      supports: item[4],
      layer: item[5]
    };
    if (indexByIdentifier !== -1) {
      stylesInDOM[indexByIdentifier].references++;
      stylesInDOM[indexByIdentifier].updater(obj);
    } else {
      var updater = addElementStyle(obj, options);
      options.byIndex = i;
      stylesInDOM.splice(i, 0, {
        identifier: identifier,
        updater: updater,
        references: 1
      });
    }
    identifiers.push(identifier);
  }
  return identifiers;
}
function addElementStyle(obj, options) {
  var api = options.domAPI(options);
  api.update(obj);
  var updater = function updater(newObj) {
    if (newObj) {
      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap && newObj.supports === obj.supports && newObj.layer === obj.layer) {
        return;
      }
      api.update(obj = newObj);
    } else {
      api.remove();
    }
  };
  return updater;
}
module.exports = function (list, options) {
  options = options || {};
  list = list || [];
  var lastIdentifiers = modulesToDom(list, options);
  return function update(newList) {
    newList = newList || [];
    for (var i = 0; i < lastIdentifiers.length; i++) {
      var identifier = lastIdentifiers[i];
      var index = getIndexByIdentifier(identifier);
      stylesInDOM[index].references--;
    }
    var newLastIdentifiers = modulesToDom(newList, options);
    for (var _i = 0; _i < lastIdentifiers.length; _i++) {
      var _identifier = lastIdentifiers[_i];
      var _index = getIndexByIdentifier(_identifier);
      if (stylesInDOM[_index].references === 0) {
        stylesInDOM[_index].updater();
        stylesInDOM.splice(_index, 1);
      }
    }
    lastIdentifiers = newLastIdentifiers;
  };
};

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/insertBySelector.js":
/*!********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/insertBySelector.js ***!
  \********************************************************************/
/***/ ((module) => {

"use strict";


var memo = {};

/* istanbul ignore next  */
function getTarget(target) {
  if (typeof memo[target] === "undefined") {
    var styleTarget = document.querySelector(target);

    // Special case to return head of iframe instead of iframe itself
    if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {
      try {
        // This will throw an exception if access to iframe is blocked
        // due to cross-origin restrictions
        styleTarget = styleTarget.contentDocument.head;
      } catch (e) {
        // istanbul ignore next
        styleTarget = null;
      }
    }
    memo[target] = styleTarget;
  }
  return memo[target];
}

/* istanbul ignore next  */
function insertBySelector(insert, style) {
  var target = getTarget(insert);
  if (!target) {
    throw new Error("Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.");
  }
  target.appendChild(style);
}
module.exports = insertBySelector;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/insertStyleElement.js":
/*!**********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/insertStyleElement.js ***!
  \**********************************************************************/
/***/ ((module) => {

"use strict";


/* istanbul ignore next  */
function insertStyleElement(options) {
  var element = document.createElement("style");
  options.setAttributes(element, options.attributes);
  options.insert(element, options.options);
  return element;
}
module.exports = insertStyleElement;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js":
/*!**********************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js ***!
  \**********************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";


/* istanbul ignore next  */
function setAttributesWithoutAttributes(styleElement) {
  var nonce =  true ? __webpack_require__.nc : 0;
  if (nonce) {
    styleElement.setAttribute("nonce", nonce);
  }
}
module.exports = setAttributesWithoutAttributes;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/styleDomAPI.js":
/*!***************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/styleDomAPI.js ***!
  \***************************************************************/
/***/ ((module) => {

"use strict";


/* istanbul ignore next  */
function apply(styleElement, options, obj) {
  var css = "";
  if (obj.supports) {
    css += "@supports (".concat(obj.supports, ") {");
  }
  if (obj.media) {
    css += "@media ".concat(obj.media, " {");
  }
  var needLayer = typeof obj.layer !== "undefined";
  if (needLayer) {
    css += "@layer".concat(obj.layer.length > 0 ? " ".concat(obj.layer) : "", " {");
  }
  css += obj.css;
  if (needLayer) {
    css += "}";
  }
  if (obj.media) {
    css += "}";
  }
  if (obj.supports) {
    css += "}";
  }
  var sourceMap = obj.sourceMap;
  if (sourceMap && typeof btoa !== "undefined") {
    css += "\n/*# sourceMappingURL=data:application/json;base64,".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), " */");
  }

  // For old IE
  /* istanbul ignore if  */
  options.styleTagTransform(css, styleElement, options.options);
}
function removeStyleElement(styleElement) {
  // istanbul ignore if
  if (styleElement.parentNode === null) {
    return false;
  }
  styleElement.parentNode.removeChild(styleElement);
}

/* istanbul ignore next  */
function domAPI(options) {
  if (typeof document === "undefined") {
    return {
      update: function update() {},
      remove: function remove() {}
    };
  }
  var styleElement = options.insertStyleElement(options);
  return {
    update: function update(obj) {
      apply(styleElement, options, obj);
    },
    remove: function remove() {
      removeStyleElement(styleElement);
    }
  };
}
module.exports = domAPI;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/styleTagTransform.js":
/*!*********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/styleTagTransform.js ***!
  \*********************************************************************/
/***/ ((module) => {

"use strict";


/* istanbul ignore next  */
function styleTagTransform(css, styleElement) {
  if (styleElement.styleSheet) {
    styleElement.styleSheet.cssText = css;
  } else {
    while (styleElement.firstChild) {
      styleElement.removeChild(styleElement.firstChild);
    }
    styleElement.appendChild(document.createTextNode(css));
  }
}
module.exports = styleTagTransform;

/***/ }),

/***/ "./node_modules/toastify-js/src/toastify.js":
/*!**************************************************!*\
  !*** ./node_modules/toastify-js/src/toastify.js ***!
  \**************************************************/
/***/ (function(module) {

/*!
 * Toastify js 1.12.0
 * https://github.com/apvarun/toastify-js
 * @license MIT licensed
 *
 * Copyright (C) 2018 Varun A P
 */
(function(root, factory) {
  if ( true && module.exports) {
    module.exports = factory();
  } else {
    root.Toastify = factory();
  }
})(this, function(global) {
  // Object initialization
  var Toastify = function(options) {
      // Returning a new init object
      return new Toastify.lib.init(options);
    },
    // Library version
    version = "1.12.0";

  // Set the default global options
  Toastify.defaults = {
    oldestFirst: true,
    text: "Toastify is awesome!",
    node: undefined,
    duration: 3000,
    selector: undefined,
    callback: function () {
    },
    destination: undefined,
    newWindow: false,
    close: false,
    gravity: "toastify-top",
    positionLeft: false,
    position: '',
    backgroundColor: '',
    avatar: "",
    className: "",
    stopOnFocus: true,
    onClick: function () {
    },
    offset: {x: 0, y: 0},
    escapeMarkup: true,
    ariaLive: 'polite',
    style: {background: ''}
  };

  // Defining the prototype of the object
  Toastify.lib = Toastify.prototype = {
    toastify: version,

    constructor: Toastify,

    // Initializing the object with required parameters
    init: function(options) {
      // Verifying and validating the input object
      if (!options) {
        options = {};
      }

      // Creating the options object
      this.options = {};

      this.toastElement = null;

      // Validating the options
      this.options.text = options.text || Toastify.defaults.text; // Display message
      this.options.node = options.node || Toastify.defaults.node;  // Display content as node
      this.options.duration = options.duration === 0 ? 0 : options.duration || Toastify.defaults.duration; // Display duration
      this.options.selector = options.selector || Toastify.defaults.selector; // Parent selector
      this.options.callback = options.callback || Toastify.defaults.callback; // Callback after display
      this.options.destination = options.destination || Toastify.defaults.destination; // On-click destination
      this.options.newWindow = options.newWindow || Toastify.defaults.newWindow; // Open destination in new window
      this.options.close = options.close || Toastify.defaults.close; // Show toast close icon
      this.options.gravity = options.gravity === "bottom" ? "toastify-bottom" : Toastify.defaults.gravity; // toast position - top or bottom
      this.options.positionLeft = options.positionLeft || Toastify.defaults.positionLeft; // toast position - left or right
      this.options.position = options.position || Toastify.defaults.position; // toast position - left or right
      this.options.backgroundColor = options.backgroundColor || Toastify.defaults.backgroundColor; // toast background color
      this.options.avatar = options.avatar || Toastify.defaults.avatar; // img element src - url or a path
      this.options.className = options.className || Toastify.defaults.className; // additional class names for the toast
      this.options.stopOnFocus = options.stopOnFocus === undefined ? Toastify.defaults.stopOnFocus : options.stopOnFocus; // stop timeout on focus
      this.options.onClick = options.onClick || Toastify.defaults.onClick; // Callback after click
      this.options.offset = options.offset || Toastify.defaults.offset; // toast offset
      this.options.escapeMarkup = options.escapeMarkup !== undefined ? options.escapeMarkup : Toastify.defaults.escapeMarkup;
      this.options.ariaLive = options.ariaLive || Toastify.defaults.ariaLive;
      this.options.style = options.style || Toastify.defaults.style;
      if(options.backgroundColor) {
        this.options.style.background = options.backgroundColor;
      }

      // Returning the current object for chaining functions
      return this;
    },

    // Building the DOM element
    buildToast: function() {
      // Validating if the options are defined
      if (!this.options) {
        throw "Toastify is not initialized";
      }

      // Creating the DOM object
      var divElement = document.createElement("div");
      divElement.className = "toastify on " + this.options.className;

      // Positioning toast to left or right or center
      if (!!this.options.position) {
        divElement.className += " toastify-" + this.options.position;
      } else {
        // To be depreciated in further versions
        if (this.options.positionLeft === true) {
          divElement.className += " toastify-left";
          console.warn('Property `positionLeft` will be depreciated in further versions. Please use `position` instead.')
        } else {
          // Default position
          divElement.className += " toastify-right";
        }
      }

      // Assigning gravity of element
      divElement.className += " " + this.options.gravity;

      if (this.options.backgroundColor) {
        // This is being deprecated in favor of using the style HTML DOM property
        console.warn('DEPRECATION NOTICE: "backgroundColor" is being deprecated. Please use the "style.background" property.');
      }

      // Loop through our style object and apply styles to divElement
      for (var property in this.options.style) {
        divElement.style[property] = this.options.style[property];
      }

      // Announce the toast to screen readers
      if (this.options.ariaLive) {
        divElement.setAttribute('aria-live', this.options.ariaLive)
      }

      // Adding the toast message/node
      if (this.options.node && this.options.node.nodeType === Node.ELEMENT_NODE) {
        // If we have a valid node, we insert it
        divElement.appendChild(this.options.node)
      } else {
        if (this.options.escapeMarkup) {
          divElement.innerText = this.options.text;
        } else {
          divElement.innerHTML = this.options.text;
        }

        if (this.options.avatar !== "") {
          var avatarElement = document.createElement("img");
          avatarElement.src = this.options.avatar;

          avatarElement.className = "toastify-avatar";

          if (this.options.position == "left" || this.options.positionLeft === true) {
            // Adding close icon on the left of content
            divElement.appendChild(avatarElement);
          } else {
            // Adding close icon on the right of content
            divElement.insertAdjacentElement("afterbegin", avatarElement);
          }
        }
      }

      // Adding a close icon to the toast
      if (this.options.close === true) {
        // Create a span for close element
        var closeElement = document.createElement("button");
        closeElement.type = "button";
        closeElement.setAttribute("aria-label", "Close");
        closeElement.className = "toast-close";
        closeElement.innerHTML = "&#10006;";

        // Triggering the removal of toast from DOM on close click
        closeElement.addEventListener(
          "click",
          function(event) {
            event.stopPropagation();
            this.removeElement(this.toastElement);
            window.clearTimeout(this.toastElement.timeOutValue);
          }.bind(this)
        );

        //Calculating screen width
        var width = window.innerWidth > 0 ? window.innerWidth : screen.width;

        // Adding the close icon to the toast element
        // Display on the right if screen width is less than or equal to 360px
        if ((this.options.position == "left" || this.options.positionLeft === true) && width > 360) {
          // Adding close icon on the left of content
          divElement.insertAdjacentElement("afterbegin", closeElement);
        } else {
          // Adding close icon on the right of content
          divElement.appendChild(closeElement);
        }
      }

      // Clear timeout while toast is focused
      if (this.options.stopOnFocus && this.options.duration > 0) {
        var self = this;
        // stop countdown
        divElement.addEventListener(
          "mouseover",
          function(event) {
            window.clearTimeout(divElement.timeOutValue);
          }
        )
        // add back the timeout
        divElement.addEventListener(
          "mouseleave",
          function() {
            divElement.timeOutValue = window.setTimeout(
              function() {
                // Remove the toast from DOM
                self.removeElement(divElement);
              },
              self.options.duration
            )
          }
        )
      }

      // Adding an on-click destination path
      if (typeof this.options.destination !== "undefined") {
        divElement.addEventListener(
          "click",
          function(event) {
            event.stopPropagation();
            if (this.options.newWindow === true) {
              window.open(this.options.destination, "_blank");
            } else {
              window.location = this.options.destination;
            }
          }.bind(this)
        );
      }

      if (typeof this.options.onClick === "function" && typeof this.options.destination === "undefined") {
        divElement.addEventListener(
          "click",
          function(event) {
            event.stopPropagation();
            this.options.onClick();
          }.bind(this)
        );
      }

      // Adding offset
      if(typeof this.options.offset === "object") {

        var x = getAxisOffsetAValue("x", this.options);
        var y = getAxisOffsetAValue("y", this.options);

        var xOffset = this.options.position == "left" ? x : "-" + x;
        var yOffset = this.options.gravity == "toastify-top" ? y : "-" + y;

        divElement.style.transform = "translate(" + xOffset + "," + yOffset + ")";

      }

      // Returning the generated element
      return divElement;
    },

    // Displaying the toast
    showToast: function() {
      // Creating the DOM object for the toast
      this.toastElement = this.buildToast();

      // Getting the root element to with the toast needs to be added
      var rootElement;
      if (typeof this.options.selector === "string") {
        rootElement = document.getElementById(this.options.selector);
      } else if (this.options.selector instanceof HTMLElement || (typeof ShadowRoot !== 'undefined' && this.options.selector instanceof ShadowRoot)) {
        rootElement = this.options.selector;
      } else {
        rootElement = document.body;
      }

      // Validating if root element is present in DOM
      if (!rootElement) {
        throw "Root element is not defined";
      }

      // Adding the DOM element
      var elementToInsert = Toastify.defaults.oldestFirst ? rootElement.firstChild : rootElement.lastChild;
      rootElement.insertBefore(this.toastElement, elementToInsert);

      // Repositioning the toasts in case multiple toasts are present
      Toastify.reposition();

      if (this.options.duration > 0) {
        this.toastElement.timeOutValue = window.setTimeout(
          function() {
            // Remove the toast from DOM
            this.removeElement(this.toastElement);
          }.bind(this),
          this.options.duration
        ); // Binding `this` for function invocation
      }

      // Supporting function chaining
      return this;
    },

    hideToast: function() {
      if (this.toastElement.timeOutValue) {
        clearTimeout(this.toastElement.timeOutValue);
      }
      this.removeElement(this.toastElement);
    },

    // Removing the element from the DOM
    removeElement: function(toastElement) {
      // Hiding the element
      // toastElement.classList.remove("on");
      toastElement.className = toastElement.className.replace(" on", "");

      // Removing the element from DOM after transition end
      window.setTimeout(
        function() {
          // remove options node if any
          if (this.options.node && this.options.node.parentNode) {
            this.options.node.parentNode.removeChild(this.options.node);
          }

          // Remove the element from the DOM, only when the parent node was not removed before.
          if (toastElement.parentNode) {
            toastElement.parentNode.removeChild(toastElement);
          }

          // Calling the callback function
          this.options.callback.call(toastElement);

          // Repositioning the toasts again
          Toastify.reposition();
        }.bind(this),
        400
      ); // Binding `this` for function invocation
    },
  };

  // Positioning the toasts on the DOM
  Toastify.reposition = function() {

    // Top margins with gravity
    var topLeftOffsetSize = {
      top: 15,
      bottom: 15,
    };
    var topRightOffsetSize = {
      top: 15,
      bottom: 15,
    };
    var offsetSize = {
      top: 15,
      bottom: 15,
    };

    // Get all toast messages on the DOM
    var allToasts = document.getElementsByClassName("toastify");

    var classUsed;

    // Modifying the position of each toast element
    for (var i = 0; i < allToasts.length; i++) {
      // Getting the applied gravity
      if (containsClass(allToasts[i], "toastify-top") === true) {
        classUsed = "toastify-top";
      } else {
        classUsed = "toastify-bottom";
      }

      var height = allToasts[i].offsetHeight;
      classUsed = classUsed.substr(9, classUsed.length-1)
      // Spacing between toasts
      var offset = 15;

      var width = window.innerWidth > 0 ? window.innerWidth : screen.width;

      // Show toast in center if screen with less than or equal to 360px
      if (width <= 360) {
        // Setting the position
        allToasts[i].style[classUsed] = offsetSize[classUsed] + "px";

        offsetSize[classUsed] += height + offset;
      } else {
        if (containsClass(allToasts[i], "toastify-left") === true) {
          // Setting the position
          allToasts[i].style[classUsed] = topLeftOffsetSize[classUsed] + "px";

          topLeftOffsetSize[classUsed] += height + offset;
        } else {
          // Setting the position
          allToasts[i].style[classUsed] = topRightOffsetSize[classUsed] + "px";

          topRightOffsetSize[classUsed] += height + offset;
        }
      }
    }

    // Supporting function chaining
    return this;
  };

  // Helper function to get offset.
  function getAxisOffsetAValue(axis, options) {

    if(options.offset[axis]) {
      if(isNaN(options.offset[axis])) {
        return options.offset[axis];
      }
      else {
        return options.offset[axis] + 'px';
      }
    }

    return '0px';

  }

  function containsClass(elem, yourClass) {
    if (!elem || typeof yourClass !== "string") {
      return false;
    } else if (
      elem.className &&
      elem.className
        .trim()
        .split(/\s+/gi)
        .indexOf(yourClass) > -1
    ) {
      return true;
    } else {
      return false;
    }
  }

  // Setting up the prototype for the init object
  Toastify.lib.init.prototype = Toastify.lib;

  // Returning the Toastify function to be assigned to the window object/module
  return Toastify;
});


/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "React" ***!
  \************************/
/***/ ((module) => {

"use strict";
module.exports = window["React"];

/***/ }),

/***/ "@learnpress/quiz":
/*!******************************!*\
  !*** external ["LP","quiz"] ***!
  \******************************/
/***/ ((module) => {

"use strict";
module.exports = window["LP"]["quiz"];

/***/ }),

/***/ "@wordpress/api-fetch":
/*!**********************************!*\
  !*** external ["wp","apiFetch"] ***!
  \**********************************/
/***/ ((module) => {

"use strict";
module.exports = window["wp"]["apiFetch"];

/***/ }),

/***/ "@wordpress/element":
/*!*********************************!*\
  !*** external ["wp","element"] ***!
  \*********************************/
/***/ ((module) => {

"use strict";
module.exports = window["wp"]["element"];

/***/ }),

/***/ "@wordpress/url":
/*!*****************************!*\
  !*** external ["wp","url"] ***!
  \*****************************/
/***/ ((module) => {

"use strict";
module.exports = window["wp"]["url"];

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
/******/ 			id: moduleId,
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId].call(module.exports, module, module.exports, __webpack_require__);
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
/******/ 	/* webpack/runtime/nonce */
/******/ 	(() => {
/******/ 		__webpack_require__.nc = undefined;
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be in strict mode.
(() => {
"use strict";
/*!******************************************************!*\
  !*** ./assets/src/apps/js/frontend/single-course.js ***!
  \******************************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__),
/* harmony export */   enrollCourse: () => (/* binding */ enrollCourse),
/* harmony export */   init: () => (/* binding */ init),
/* harmony export */   initCourseSidebar: () => (/* binding */ initCourseSidebar),
/* harmony export */   initCourseTabs: () => (/* binding */ initCourseTabs)
/* harmony export */ });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _single_course_index__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./single-course/index */ "./assets/src/apps/js/frontend/single-course/index.js");
/* harmony import */ var _show_lp_overlay_complete_item__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./show-lp-overlay-complete-item */ "./assets/src/apps/js/frontend/show-lp-overlay-complete-item.js");
/* harmony import */ var _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../utils/lp-modal-overlay */ "./assets/src/apps/js/utils/lp-modal-overlay.js");
/* harmony import */ var _single_curriculum_skeleton__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./single-curriculum/skeleton */ "./assets/src/apps/js/frontend/single-curriculum/skeleton.js");
/* harmony import */ var _material__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./material */ "./assets/src/apps/js/frontend/material.js");
/* harmony import */ var _tabs_scroll__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./tabs-scroll */ "./assets/src/apps/js/frontend/tabs-scroll.js");
/* harmony import */ var _js_utils_js__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ../../../js/utils.js */ "./assets/src/js/utils.js");
/* harmony import */ var toastify_js__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! toastify-js */ "./node_modules/toastify-js/src/toastify.js");
/* harmony import */ var toastify_js__WEBPACK_IMPORTED_MODULE_8___default = /*#__PURE__*/__webpack_require__.n(toastify_js__WEBPACK_IMPORTED_MODULE_8__);
/* harmony import */ var toastify_js_src_toastify_css__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! toastify-js/src/toastify.css */ "./node_modules/toastify-js/src/toastify.css");
/* harmony import */ var _js_frontend_copy_to_clipboard_js__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ../../../js/frontend/copy-to-clipboard.js */ "./assets/src/js/frontend/copy-to-clipboard.js");











/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (_single_course_index__WEBPACK_IMPORTED_MODULE_1__["default"]);
const init = () => {
  wp.element.render((0,react__WEBPACK_IMPORTED_MODULE_0__.createElement)(_single_course_index__WEBPACK_IMPORTED_MODULE_1__["default"], null));
};
const $ = jQuery;
const initCourseTabs = function () {
  $('#learn-press-course-tabs').on('change', 'input[name="learn-press-course-tab-radio"]', function (e) {
    const selectedTab = $('input[name="learn-press-course-tab-radio"]:checked').val();
    LP.Cookies.set('course-tab', selectedTab);
    $('label[for="' + $(e.target).attr('id') + '"]').closest('li').addClass('active').siblings().removeClass('active');
  });
};
const initCourseSidebar = function initCourseSidebar() {
  const $sidebar = $('.course-summary-sidebar');
  if (!$sidebar.length) {
    return;
  }
  const $window = $(window);
  const $scrollable = $sidebar.children();
  const offset = $sidebar.offset();
  let scrollTop = 0;
  const maxHeight = $sidebar.height();
  const scrollHeight = $scrollable.height();
  const options = {
    offsetTop: 32
  };
  const onScroll = function () {
    scrollTop = $window.scrollTop();
    const top = scrollTop - offset.top + options.offsetTop;
    if (top < 0) {
      $sidebar.removeClass('slide-top slide-down');
      $scrollable.css('top', '');
      return;
    }
    if (top > maxHeight - scrollHeight) {
      $sidebar.removeClass('slide-down').addClass('slide-top');
      $scrollable.css('top', maxHeight - scrollHeight);
    } else {
      $sidebar.removeClass('slide-top').addClass('slide-down');
      $scrollable.css('top', options.offsetTop);
    }
  };
  $window.on('scroll.fixed-course-sidebar', onScroll).trigger('scroll.fixed-course-sidebar');
};

// Rest API Enroll course - Nhamdv.
const enrollCourse = () => {
  const formEnrolls = document.querySelectorAll('form.enroll-course');
  if (formEnrolls.length > 0) {
    formEnrolls.forEach(formEnroll => {
      const submit = async (id, btnEnroll) => {
        const status = 'error';
        try {
          const response = await wp.apiFetch({
            path: 'lp/v1/courses/enroll-course',
            method: 'POST',
            data: {
              id
            }
          });
          const {
            status,
            data: {
              redirect
            },
            message
          } = response;
          if (status === 'success') {
            btnEnroll.remove();
          } else {
            (0,_js_utils_js__WEBPACK_IMPORTED_MODULE_7__.lpSetLoadingEl)(btnEnroll, 0);
            throw new Error(message);
          }
          if (message && status) {
            formEnroll.innerHTML += `<div class="learn-press-message ${status}">${message}</div>`;
            if (redirect) {
              window.location.href = redirect;
            }
          }
        } catch (error) {
          toastify_js__WEBPACK_IMPORTED_MODULE_8___default()({
            text: error.message,
            gravity: lpData.toast.gravity,
            // `top` or `bottom`
            position: lpData.toast.position,
            // `left`, `center` or `right`
            className: `${lpData.toast.classPrefix} ${status}`,
            close: lpData.toast.close == 1,
            stopOnFocus: lpData.toast.stopOnFocus == 1,
            duration: lpData.toast.duration
          }).showToast();
        }
      };
      formEnroll.addEventListener('submit', event => {
        event.preventDefault();
        const id = formEnroll.querySelector('input[name=enroll-course]').value;
        const btnEnroll = formEnroll.querySelector('button.button-enroll-course');
        (0,_js_utils_js__WEBPACK_IMPORTED_MODULE_7__.lpSetLoadingEl)(btnEnroll, 1);
        submit(id, btnEnroll);
      });
    });
  }

  // Reload when press back button in chrome.
  if (document.querySelector('.course-detail-info') !== null) {
    window.addEventListener('pageshow', event => {
      const hasCache = event.persisted || typeof window.performance != 'undefined' && String(window.performance.getEntriesByType('navigation')[0].type) == 'back_forward';
      if (hasCache) {
        location.reload();
      }
    });
  }
};

// Rest API purchase course - Nhamdv.
const purchaseCourse = () => {
  const forms = document.querySelectorAll('form.purchase-course');
  if (forms.length > 0) {
    forms.forEach(form => {
      // Allow Repurchase.
      const allowRepurchase = () => {
        const continueRepurchases = document.querySelectorAll('.lp_allow_repurchase_select');
        continueRepurchases.forEach(repurchase => {
          const radios = repurchase.querySelectorAll('[name=_lp_allow_repurchase_type]');
          for (let i = 0, length = radios.length; i < length; i++) {
            if (radios[i].checked) {
              const repurchaseType = radios[i].value;
              const id = form.querySelector('input[name=purchase-course]').value;
              const btnBuyNow = form.querySelector('button.button-purchase-course');
              (0,_js_utils_js__WEBPACK_IMPORTED_MODULE_7__.lpSetLoadingEl)(btnBuyNow, 1);
              submit(id, btnBuyNow, repurchaseType);
              break;
            }
          }
        });
      };
      const submit = async (id, btn, repurchaseType = false) => {
        const status = 'error';
        try {
          const response = await wp.apiFetch({
            path: 'lp/v1/courses/purchase-course',
            method: 'POST',
            data: {
              id,
              repurchaseType
            }
          });
          const {
            status,
            data: {
              redirect,
              type,
              html,
              titlePopup
            },
            message
          } = response;
          if (status === 'success') {
            if (type === 'allow_repurchase') {
              (0,_js_utils_js__WEBPACK_IMPORTED_MODULE_7__.lpSetLoadingEl)(btn, 0);
            } else {
              btn.remove();
            }
          } else {
            (0,_js_utils_js__WEBPACK_IMPORTED_MODULE_7__.lpSetLoadingEl)(btn, 0);
            throw new Error(message);
          }
          if (type === 'allow_repurchase' && status === 'success') {
            if (!form.querySelector('.lp_allow_repurchase_select')) {
              if (!_utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__["default"].init()) {
                return;
              }
              _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__["default"].elLPOverlay.show();
              _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__["default"].setTitleModal(titlePopup || '');
              _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__["default"].setContentModal(html);
              _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__["default"].callBackYes = () => {
                _utils_lp_modal_overlay__WEBPACK_IMPORTED_MODULE_3__["default"].elLPOverlay.hide();
                allowRepurchase();
              };
            }
          } else if (message && status) {
            form.innerHTML += `<div class="learn-press-message ${status}">${message}</div>`;
            if ('success' === status && redirect) {
              window.location.href = redirect;
            }
          }
        } catch (error) {
          toastify_js__WEBPACK_IMPORTED_MODULE_8___default()({
            text: error.message,
            gravity: lpData.toast.gravity,
            // `top` or `bottom`
            position: lpData.toast.position,
            // `left`, `center` or `right`
            className: `${lpData.toast.classPrefix} ${status}`,
            close: lpData.toast.close == 1,
            stopOnFocus: lpData.toast.stopOnFocus == 1,
            duration: lpData.toast.duration
          }).showToast();
        }
      };
      form.addEventListener('submit', event => {
        event.preventDefault();
        const id = form.querySelector('input[name=purchase-course]').value;
        const btn = form.querySelector('button.button-purchase-course');
        (0,_js_utils_js__WEBPACK_IMPORTED_MODULE_7__.lpSetLoadingEl)(btn, 1);
        submit(id, btn);
      });
    });
  }
};
const retakeCourse = () => {
  const elFormRetakeCourses = document.querySelectorAll('.lp-form-retake-course');
  if (!elFormRetakeCourses.length) {
    return;
  }
  elFormRetakeCourses.forEach(elFormRetakeCourse => {
    const elButtonRetakeCourses = elFormRetakeCourse.querySelector('.button-retake-course');
    const elCourseId = elFormRetakeCourse.querySelector('[name=retake-course]').value;
    const elAjaxMessage = elFormRetakeCourse.querySelector('.lp-ajax-message');
    const submit = elButtonRetakeCourse => {
      wp.apiFetch({
        path: '/lp/v1/courses/retake-course',
        method: 'POST',
        data: {
          id: elCourseId
        }
      }).then(res => {
        const {
          status,
          message,
          data
        } = res;
        elAjaxMessage.innerHTML = message;
        if (undefined != status && status === 'success') {
          elButtonRetakeCourse.style.display = 'none';
          setTimeout(() => {
            window.location.replace(data.url_redirect);
          }, 1000);
        } else {
          elAjaxMessage.classList.add('error');
        }
      }).catch(err => {
        elAjaxMessage.classList.add('error');
        elAjaxMessage.innerHTML = 'error: ' + err.message;
      }).then(() => {
        elButtonRetakeCourse.classList.remove('loading');
        elButtonRetakeCourse.disabled = false;
        elAjaxMessage.style.display = 'block';
      });
    };
    elFormRetakeCourse.addEventListener('submit', e => {
      e.preventDefault();
    });
    elButtonRetakeCourses.addEventListener('click', e => {
      e.preventDefault();
      elButtonRetakeCourses.classList.add('loading');
      elButtonRetakeCourses.disabled = true;
      submit(elButtonRetakeCourses);
    });
  });
};

// Rest API load content course progress - Nhamdv.
const courseProgress = () => {
  const elements = document.querySelectorAll('.lp-course-progress-wrapper');
  if (!elements.length) {
    return;
  }
  if ('IntersectionObserver' in window) {
    const eleObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const ele = entry.target;
          setTimeout(function () {
            getResponse(ele);
          }, 600);
          eleObserver.unobserve(ele);
        }
      });
    });
    [...elements].map(ele => eleObserver.observe(ele));
  }
  const getResponse = async ele => {
    let url = 'lp/v1/lazy-load/course-progress';
    if (lpData.urlParams.hasOwnProperty('lang')) {
      url += '?lang=' + lpData.urlParams.lang;
    }
    const response = await wp.apiFetch({
      path: url,
      method: 'POST',
      data: {
        courseId: lpGlobalSettings.post_id || '',
        userId: lpData.user_id || ''
      }
    });
    const {
      data
    } = response;
    ele.innerHTML = data;
  };
};
const accordionExtraTab = () => {
  const elements = document.querySelectorAll('.course-extra-box');
  [...elements].map(ele => {
    const title = ele.querySelector('.course-extra-box__title');
    ele.classList.remove('active');
    const content = ele.querySelector('.course-extra-box__content');
    content.style.height = '0';
    title.addEventListener('click', () => {
      const isActive = ele.classList.contains('active');
      [...elements].forEach(otherEle => {
        if (otherEle !== ele) {
          otherEle.classList.remove('active');
          otherEle.querySelector('.course-extra-box__content').style.height = '0';
        }
      });
      if (isActive) {
        ele.classList.remove('active');
        content.style.height = '0';
      } else {
        ele.classList.add('active');
        content.style.height = content.scrollHeight + 'px';
      }
    });
  });
};
const courseContinue = () => {
  const formContinue = document.querySelectorAll('form.continue-course');
  if (formContinue.length && lpData.user_id > 0) {
    const getResponse = async ele => {
      const response = await wp.apiFetch({
        path: 'lp/v1/courses/continue-course',
        method: 'POST',
        data: {
          courseId: lpGlobalSettings.post_id || '',
          userId: lpGlobalSettings.user_id || ''
        }
      });
      return response;
    };
    getResponse(formContinue).then(function (result) {
      if (result.status === 'success') {
        formContinue.forEach(form => {
          form.style.display = 'inline-block';
          form.action = result.data;
        });
      }
    });
  }
};

document.addEventListener('DOMContentLoaded', function () {
  const $popup = $('#popup-course');
  let timerClearScroll;
  const $curriculum = $('#learn-press-course-curriculum');
  accordionExtraTab();
  initCourseTabs();
  initCourseSidebar();
  enrollCourse();
  purchaseCourse();
  retakeCourse();
  courseProgress();
  courseContinue();
  _show_lp_overlay_complete_item__WEBPACK_IMPORTED_MODULE_2__["default"].init();
  (0,_material__WEBPACK_IMPORTED_MODULE_5__["default"])();
  //courseCurriculumSkeleton();
  (0,_tabs_scroll__WEBPACK_IMPORTED_MODULE_6__["default"])();
  (0,_js_frontend_copy_to_clipboard_js__WEBPACK_IMPORTED_MODULE_10__["default"])();
});
const detectedElCurriculum = setInterval(function () {
  const elementCurriculum = document.querySelector('.learnpress-course-curriculum');
  if (elementCurriculum) {
    (0,_single_curriculum_skeleton__WEBPACK_IMPORTED_MODULE_4__["default"])();
    clearInterval(detectedElCurriculum);
  }
}, 1);

// Add callback for Thimkits
LP.Hook.addAction('lp_course_curriculum_skeleton', function (id) {
  (0,_single_curriculum_skeleton__WEBPACK_IMPORTED_MODULE_4__["default"])(id);
});
})();

/******/ })()
;
//# sourceMappingURL=single-course.js.map