# Pin npm packages by running ./bin/importmap
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/custom", under: "custom", preload: true
pin "select2", to: "https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"
