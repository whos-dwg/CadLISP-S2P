(defun c:S2P (/ *error* oldCmdecho ss i en precision result failed cmdResult)

  (defun *error* (msg)
    (if oldCmdecho
      (setvar "CMDECHO" oldCmdecho)
    )
    (if (and msg
             (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (setq oldCmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (initget 6)
  (setq precision (getint "\nPolyline precision <10>: "))
  (if (null precision)
    (setq precision 10)
  )
  (if (> precision 99)
    (setq precision 99)
  )

  (setq ss (ssget '((0 . "SPLINE"))))

  (if ss
    (progn
      (setq i 0
            result 0
            failed 0)
      (repeat (sslength ss)
        (setq en (ssname ss i))
        (if (and en (entget en))
          (progn
            (setq cmdResult
              (vl-catch-all-apply
                'vl-cmdf
                (list "_.SPLINEDIT" en "_P" precision)
              )
            )
            (if (vl-catch-all-error-p cmdResult)
              (setq failed (1+ failed))
              (setq result (1+ result))
            )
          )
          (setq failed (1+ failed))
        )
        (setq i (1+ i))
      )
      (princ
        (strcat
          "\nConverted "
          (itoa result)
          " spline(s) to polylines. Precision: "
          (itoa precision)
          ". Failed: "
          (itoa failed)
          "."
        )
      )
    )
    (princ "\nNo splines selected.")
  )

  (setvar "CMDECHO" oldCmdecho)
  (princ)
)
