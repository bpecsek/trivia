
(defpackage :optima.level1.test
  (:use :cl :eos :optima.level1 :alexandria))
(in-package :optima.level1.test)

(def-suite :optima.level1)
(in-suite :optima.level1)

(defmacro is-match (arg pattern)
  `(is-true (match ,arg (,pattern t))))
(defmacro is-not-match (arg pattern)
  `(is-false (match ,arg (,pattern t))))

(test variables
  ;; in layer1, variable binding order is strictly defined,
  ;; so it should be compared with equal
  (is (equal '(x y)
             (variables `(guard x t (car x) (guard y t)))))


  ;; in layer1, or-pattern binding is strict, so the variable set should be set-equal
  (signals error
    (variables `(or (guard x t)
                    (guard y t))))
  (is (set-equal '(x y)
                 (variables `(or (guard x t (car x) (guard y t))
                                 (guard y t (car y) (guard x t))))))
  (is (set-equal '(x)
                 (variables `(or (guard x t)
                                 (guard x t)))))
  ;; to emulate soft binding (defaulted to nil), use below:
  (is (set-equal '(x y)
                 (variables `(or (guard x t nil (guard y t))
                                 (guard y t (car y) (guard x t)))))))


(test match

  (is-match '(1 2)
            (guard it (consp it)
                   (car it) (guard car (= 1 car))
                   (cadr it) (guard cadr (= 2 cadr))))

  (is-not-match '(1 2)
                (guard it (consp it)
                       (car it) (guard car (= 1 car))
                       (cadr it) (guard cadr (= 1 cadr))))

  (is-match '(1 2)
            (or (guard it (consp it)
                       (car it) (guard car (= 1 car))
                       (cadr it) (guard cadr (= 2 cadr)))
                (guard it (consp it) ;;; this does not happen under level-2 optimization
                                     ;;; because checks for (consp it) is
                                     ;;; duplicated
                       (car it) (guard car (= 2 car))
                       (cadr it) (guard cadr (= 1 cadr)))))
  (is-match '(2 1)
            (or (guard it (consp it)
                       (car it) (guard car (= 1 car))
                       (cadr it) (guard cadr (= 2 cadr)))
                (guard it (consp it)
                       (car it) (guard car (= 2 car))
                       (cadr it) (guard cadr (= 1 cadr)))))
  (is-not-match '(2 2)
                (or (guard it (consp it)
                           (car it) (guard car (= 1 car))
                           (cadr it) (guard cadr (= 2 cadr)))
                    (guard it (consp it)
                           (car it) (guard car (= 2 car))
                           (cadr it) (guard cadr (= 1 cadr))))))


(eval-when (:load-toplevel :execute)
  (run! :optima.level1))

