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

  // Handler para links que devem abrir em modal (lógica do antigo contacts.js.erb)
  $('body').on('click', 'a.contact-new, a.contact-edit, a.bi-analysis', function(e) {
    e.preventDefault();
    var url = $(this).attr('href');
    var isBI = $(this).hasClass('bi-analysis');
    
    // Se o modal já existe, não faz nada (previne duplo clique)
    if ($('#ajax-modal').length > 0) {
      return;
    }

    // Cria um placeholder para o modal
    $('body').append('<div id="ajax-modal" style="display:none;"></div>');

    // Busca o conteúdo do formulário
    $.get(url, function(data) {
      // O próprio new.js.erb vai preencher o #ajax-modal e chamar showModal()
    }).fail(function() {
      console.error('Falha ao carregar conteúdo do modal.');
      $('#ajax-modal').remove(); // Limpa em caso de erro
    });
  });

  // Inicialização do Select2 para campos de seleção
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
