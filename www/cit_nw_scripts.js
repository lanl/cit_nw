// Change the action button color on user click 
 $(document).on('click', '.cit-nw-css-act-btn-color', function() {
      $('.cit-nw-css-act-btn-color').removeClass('active');
      $(this).addClass('active');
    });
    
//Autopopulate text input: Auto click "PMID Clusters" button  
// This waits for an element to appear before clicking it    
function waitAndClick(selector) {
  const el = document.querySelector(selector);
  if (el) {
    console.log('Found and clicking:', selector);
    el.click();
  } else {
    console.log('Waiting for:', selector);
    setTimeout(() => waitAndClick(selector), 200);
  }
}

/*
  This runs after Shiny connects.
  It checks the URL for a pmid parameter
  and automatically triggers the UI.
*/
$(document).on('shiny:connected', function() {
  const params = new URLSearchParams(window.location.search);

  if (params.has('pmid')) {
    const pmid = params.get('pmid');

    Shiny.setInputValue('cit_nw_show_pmid_cluster', pmid, { priority: 'event' });

    // Click static button
    setTimeout(() => {
      $('#cit_nw_show_pmid_cluster').click();
    }, 300);

    // Wait for dynamic button
    waitAndClick('#cit_nw_search');
  }
});

/*
If it ever fires too early
$(document).on('shiny:value', function(event) {
  if (event.name === 'cit_nw_pmid_tab') {
    waitAndClick('#cit_nw_search');
  }
});

*/

//For collapsible tree
$(document).on('shown.bs.tab', 'a[data-toggle=\"tab\"]', function (e) {
  Shiny.setInputValue('cit_tab_shown', Date.now(), {priority: 'event'});
  window.dispatchEvent(new Event('resize'));
});

//Toggle tip on the imagetiles
$(function () {
  $('[data-toggle="tooltip"]').tooltip();
});