// Connects to data-controller="tom-select"
// Assumes TomSelect is loaded globally via a <script> tag
(function() {
  // Wait for both Stimulus and TomSelect to be available
  const interval = setInterval(() => {
    if (window.Stimulus && window.TomSelect) {
      clearInterval(interval);

      const application = window.Stimulus.Application.getApplications()[0] || window.Stimulus.Application.start();
      const Controller = window.Stimulus.Controller;

      // Avoid re-registering the controller
      if (application.controllers.find(c => c.identifier === "tom-select")) {
        return;
      }

      application.register("tom-select", class extends Controller {
        static values = {
          options: { type: Object, default: {} },
          plugins: { type: Array, default: [] },
          create: { type: Boolean, default: false },
          url: String,
          targetId: String,
          targetGroupId: String,
          submitOnChange: { type: Boolean, default: false }
        }

        connect() {
          if (!window.TomSelect) {
            console.error("TomSelect not found on window object");
            return;
          }

          const config = this.config;

          if (this.hasUrlValue) {
            config.load = (query, callback) => {
              if (!query.length) return callback();
              fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
                .then(response => response.json())
                .then(json => {
                  callback(json);
                }).catch(() => {
                  callback();
                });
            };
            config.shouldLoad = (query) => {
              return query.length > 0;
            };
            config.render = {
              option: function(item, escape) {
                return `<div>${escape(item.text)}</div>`;
              },
              item: function(item, escape) {
                return `<div>${escape(item.text)}</div>`;
              },
              optgroup_header: function(data, escape) {
                return '<div class="optgroup-header">' + escape(data.label) + '</div>';
              }
            };
            config.valueField = 'value';
            config.labelField = 'text';
            config.searchField = ['text'];
            config.optgroupField = 'optgroup';
            config.options = []; // Initial empty options
          }

          this.select = new window.TomSelect(this.element, config);

          if (this.submitOnChangeValue) {
            this.select.on('change', (value) => {
              if (value) {
                const [type, id] = value.split('-');
                if (type === 'contact' && this.hasTargetIdValue) {
                  document.getElementById(this.targetIdValue).value = id;
                  document.getElementById(this.targetGroupIdValue).value = ''; // Clear group ID
                } else if (type === 'group' && this.hasTargetGroupIdValue) {
                  document.getElementById(this.targetGroupIdValue).value = id;
                  document.getElementById(this.targetIdValue).value = ''; // Clear contact ID
                }
                this.element.form.requestSubmit();
              }
            });
          }
        }

        disconnect() {
          if (this.select) {
            this.select.destroy();
          }
        }

        get config() {
          const baseConfig = {
            plugins: this.pluginsValue,
            create: this.createValue,
            maxItems: 1,
            hideSelected: true,
            highlight: true,
            openOnFocus: false,
            selectOnTab: true,
            closeAfterSelect: true,
            placeholder: this.element.placeholder || 'Selecione...',
          };

          return { ...baseConfig, ...this.optionsValue };
        }
      });
    }
  }, 50); // Check every 50ms
})();