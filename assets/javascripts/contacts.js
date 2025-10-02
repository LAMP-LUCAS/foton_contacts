/* Scripts para o plugin de contatos */

$(document).ready(function() {
  // Funções de Modal (definidas globalmente para serem acessíveis por new.js.erb)
  window.showModal = function(id) {
    $('#' + id).dialog({
      modal: true,
      width: 'auto',
      resizable: false,
      close: function() {
        $(this).dialog('destroy');
      }
    });
  };

  window.hideModal = function(element) {
    $(element).closest('.ui-dialog-content').dialog('close');
  };



  
  // Confirmações de exclusão
  $('form.button_to[data-confirm]').submit(function(){
    return confirm($(this).data('confirm'));
  });
  
  // Atualização dinâmica de formulários
  function updateFormFields() {
    var type = $('#contact_contact_type').val();
    
    if (type === 'person') {
      $('.company-only').hide();
      $('.person-only').show();
    } else {
      $('.company-only').show();
      $('.person-only').hide();
    }
  }
  
  // Dispara a função no change e no load
  $('body').on('change', '#contact_contact_type', updateFormFields);
  updateFormFields();
  
  // Manipulação AJAX de formulários
  $(document).on('ajax:success', 'form[data-remote]', function(e, data) {
    if (data.success) {
      if (data.message) {
        showFlashMessage('notice', data.message);
      }
      if (data.redirect) {
        window.location.href = data.redirect;
      }
    } else {
      if (data.message) {
        showFlashMessage('error', data.message);
      }
    }
  });
  
  function showFlashMessage(type, message) {
    var html = '<div id="flash_' + type + '" class="flash ' + type + '">' +
               message +
               '<a href="#" class="close-icon">&times;</a>' +
               '</div>';
               
    $('#content').prepend(html);
    
    setTimeout(function() {
      $('#flash_' + type).fadeOut('slow', function() {
        $(this).remove();
      });
    }, 5000);
  }
  
  // Fechamento de mensagens flash
  $(document).on('click', '.flash a.close-icon', function(e) {
    e.preventDefault();
    $(this).parent().fadeOut('fast', function() {
      $(this).remove();
    });
  });

  // Atualização dinâmica dos filtros (lógica do antigo contacts.js.erb)
  var filterTimeout;
  $('#query_form').on('change', 'input, select', function() {
    clearTimeout(filterTimeout);
    filterTimeout = setTimeout(function() {
      var form = $('#query_form');
      // Assegura que a requisição seja feita como JS para obter o HTML parcial
      $.get(form.attr('action'), form.serialize(), null, 'script');
    }, 500);
  });
});


// ========= FUNÇÕES PARA VÍNCULOS COM EMPRESAS =========
function addContactEmployment() {
  const container = document.getElementById('contact-employments');
  const template = container.dataset.template;
  const regexp = new RegExp('NEW_RECORD', 'g');
  const newId = new Date().getTime();
  let newContent = template.replace(regexp, newId);
  
  // Corrige aspas quebradas (caso use template inline)
  newContent = newContent.replace(/\\/g, '');
  
  container.insertAdjacentHTML('beforeend', newContent);
  

}

function removeContactEmployment(element) {
  const field = element.closest('.contact-employment-fields');
  const destroyField = field.querySelector('input[name$="[_destroy]"]');
  if (destroyField) {
    destroyField.value = '1';
    field.style.display = 'none';
  }
}

function showTab(name) {
  document.querySelectorAll('.tab-content').forEach(tab => {
    tab.style.display = 'none';
  });
  document.querySelectorAll('.tabs li').forEach(li => {
    li.classList.remove('selected');
  });
  document.getElementById(`tab-content-${name}`).style.display = 'block';
  document.getElementById(`tab-${name}`).closest('li').classList.add('selected');
}
// ======================================================