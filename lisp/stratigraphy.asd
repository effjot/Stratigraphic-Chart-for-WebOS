;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(defpackage #:stratigraphy-system
  (:use :cl :asdf))

(in-package :stratigraphy-system)

(defsystem stratigraphy
  :name "stratigraphy"
  :version "0.2.5"
  :author "Florian Jenn"
  :licence "GPLv2"
  :description "Stratigraphy"
  :long-description "Generate stratigraphic table (HTML)and information (JSON)."

  :serial t
  :components ((:file "stratigraphy"))
  :depends-on (:cl-json))
