/* Scripts para o plugin de contatos */

$(document).ready(function() {
  // Inicialização do Select2 para campos de seleção
  // Verificar se Select2 está disponível antes de inicializar
  if ($.fn.select2) {
    $('.select2').select2({
      width: '60%',
      allowClear: true
    });
  } else {
    console.error('Select2 não está disponível. Verifique a ordem de carregamento dos scripts.');
  }
  
  // Autocompletar para campos de contato
  $('.contact-autocomplete').each(function() {
    var field = $(this);
    var url = field.data('url');
    
    field.select2({
      minimumInputLength: 1,
      ajax: {
        url: url,
        dataType: 'json',
        data: function(term) {
          return { q: term };
        },
        results: function(data) {
          return { results: data };
        }
      },
      formatResult: function(item) {
        return item.text;
      },
      formatSelection: function(item) {
        return item.text;
      }
    });
  });
  
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
  
  $('#contact_contact_type').change(updateFormFields);
  updateFormFields();
  
  // Manipulação de modais
  function showModal(id) {
    $('#' + id).dialog({
      modal: true,
      width: 'auto',
      resizable: false
    });
  }
  
  function hideModal(element) {
    $(element).closest('.ui-dialog-content').dialog('close');
  }
  
  window.showModal = showModal;
  window.hideModal = hideModal;
  
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
});