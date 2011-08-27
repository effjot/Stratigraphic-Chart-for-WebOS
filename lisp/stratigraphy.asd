;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(defpackage #:stratigraphy-asd
  (:use :cl :asdf))

(in-package :stratigraphy-asd)

(defsystem stratigraphy
  :name "stratigraphy"
  :version "0.2.5"
  :author "Florian Jenn"
  :licence "GPLv2"
  :description "Stratigraphy"
  :long-description "Generate stratigraphic table (HTML)and information (JSON)."

  :serial t
  :components ((:file "stratigraphy"))
  :depends-on ("cl-json"))
