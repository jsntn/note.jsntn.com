(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(package-refresh-contents)

(defun eh-org-clean-space (text backend info)
  "在 export 为 HTML 时，删除中文之间不必要的空格"
  ;; https://github.com/hick/emacs-chinese#%E4%B8%AD%E6%96%87%E6%96%AD%E8%A1%8C
  (when (org-export-derived-backend-p backend 'html)
    (let ((regexp "[[:multibyte:]]")
	  (string text))
      ;; org 默认将一个换行符转换为空格，但中文不需要这个空格，删除
      (setq string
	    (replace-regexp-in-string
	     (format "\\(%s\\) *\n *\\(%s\\)" regexp regexp)
	     "\\1\\2" string))
      ;; 删除粗体之前的空格
      (setq string
	    (replace-regexp-in-string
	     (format "\\(%s\\) +\\(<\\)" regexp)
	     "\\1\\2" string))
      ;; 删除粗体之后的空格
      (setq string
	    (replace-regexp-in-string
	     (format "\\(>\\) +\\(%s\\)" regexp)
	     "\\1\\2" string))
      string))
  )
(with-eval-after-load 'ox
  (add-to-list 'org-export-filter-paragraph-functions 'eh-org-clean-space)
  )

(require 'ox-publish)

;; set up the project for `ox-publish`
(defcustom base-dir "./" "base directory")
(setq org-export-html-coding-system 'utf-8-unix)
;; https://emacs.stackexchange.com/questions/50117/how-to-disable-commented-date-in-org-mode-html-export
(setq org-export-time-stamp-file nil)
;; remove the "Validate XHTML 1.0" message from HTML export
;; https://stackoverflow.com/questions/15134911/in-org-mode-how-do-i-remove-the-validate-xhtml-1-0-message-from-html-export
(setq org-html-validation-link nil)

(setq footer
      "<hr />\n<p><a href=\"//jsntn.com\">%a</a><br />%d</p>\n")

(setq org-publish-project-alist
      `(
	("notes"
	 :base-directory ,base-dir
	 :publishing-directory ,(concat base-dir "html/")
	 :base-extension "org"
	 :recursive t
	 :publishing-function org-html-publish-to-html
	 :headline-levels 4
	 :auto-preamble nil
	 ;; :html-preamble "<nav><a href=\"/\">&lt; Home</a></nav>"
	 :section-numbers nil
	 :author "Jason Tian"
	 :email "hi@jsntn.com"
	 :auto-sitemap t
	 :sitemap-filename "sitemap.org"
	 :sitemap-title "Sitemap"
	 :sitemap-sort-files anti-chronologically
	 :sitemap-file-entry-format "%d %t"

	 ;; the following removes extra headers from HTML output -- important!
	 :html-link-home "/"
	 :html-head nil ;; cleans up anything that would have been in there.
	 ;; :html-head-extra ,my-blog-extra-head
	 :html-head-include-default-style nil
	 :html-head-include-scripts nil
	 :html-viewport nil
	 :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/worg.css\"/>"

	 :html-postamble ,footer
	 ;; :with-author t
	 ;; :with-creator nil
	 ;; :with-date t
	 )
	("static"
	 :base-directory ,base-dir
	 :publishing-directory ,(concat base-dir "html/")
	 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|wav"
	 :recursive t
	 :publishing-function org-publish-attachment
	 )
	("notes" :components ("notes" "static"))
	)
      )
