
(require 'yasnippet)
(require 'elm-util)


(setq elm-snippets-dir (file-name-directory load-file-name))

;;;###autoload
(defun load-elm-snippets ()
  (let (
        (snip-dir (expand-file-name "snippets" elm-snippets-dir))
        )
    (add-to-list 'yas-snippet-dirs snip-dir)
    (yas/load-directory snip-dir)
    ))


;;;###autoload
(defun elm-mode-snippet-function ()
  (interactive)
  (yas-expand-snippet (yas-lookup-snippet "fun"))
  (evil-insert 1)
  )

;;;###autoload
(defun elm-mode-snippet-case ()
  (interactive)
  (yas-expand-snippet (yas-lookup-snippet "cas"))
  (evil-insert 1)
  )

;;;###autoload
(defun elm-mode-snippet-module ()
  (interactive)
  (yas-expand-snippet (yas-lookup-snippet "mod"))
  (evil-insert 1)
  )

;;;###autoload
(defun elm-mode-snippet-import ()
  (interactive)
  (yas-expand-snippet (yas-lookup-snippet "imp"))
  (evil-insert 1)
  )

;;;###autoload
(defun expand-snippet-maybe ()
  "Expand snippet corresponding to the current file.
This only works when yas package is installed."
  (when (and (fboundp 'yas-expand-snippet)
        (and (buffer-file-name) (not (file-exists-p (buffer-file-name)))
        (s-blank? (buffer-string))))
    (yas-minor-mode +1)
    (yas-expand-snippet (snippet-for-module))))

;;;###autoload
(defun snippet-for-module ()
  (interactive)
  (let ((module-leaf-name (last (elm--module-dir-list))))
    (cond
     ((equal module-leaf-name '("Model")) (elm-snippets--model-snippet))
     ((equal module-leaf-name '("Update")) (elm-snippets--update-snippet))
     ((equal module-leaf-name '("View")) (elm-snippets--view-snippet))
     (t (elm-snippets--module-snippet)))))

;;;###autoload
(defun elm-snippets--module-snippet ()
  (let ((module-name (elm--module-for-path)))
    (format "module %s exposing (..)\n\n\n    $1" module-name)))

;;;###autoload
(defun elm-snippets--model-snippet ()
  (let ((module-name (elm--module-for-path)))
    (format "module %s exposing (Model)\n\n\ntype alias Model =\n  {$1}" module-name)))

;;;###autoload
(defun elm-snippets--update-snippet ()
  (let ((module-name (elm--module-for-path))
        (model-import (elm--relative-module-for-path '("Model")))
        )
        (format "module %s exposing (Msg(..), update)\n\nimport %s exposing (Model)\n\n\ntype Msg\n  = NoOp\n\n\nupdate : Msg -> Model -> (Model, Cmd Msg)\nupdate msg model =\n    case msg of\n        NoOp ->\n            (model, Cmd.none)" module-name model-import)))

;;;###autoload
(defun elm-snippets--view-snippet ()
  (let ((module-name (elm--module-for-path))
        (model-import (elm--relative-module-for-path '("Model")))
        (update-import (elm--relative-module-for-path '("Update")))
        )
    (format "module %s exposing (view)\n\nimport Html exposing (..)\nimport %s exposing (Model)\nimport %s exposing (Msg(..))\n\n\nview : Model -> Html Msg\nview model =\n    Html.text \"(> ^_^ )>\"" module-name model-import update-import)))

(provide 'elm-snippets)
