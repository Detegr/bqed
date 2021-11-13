While ← {𝕩{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}𝕨@}´

# Restore terminal state and exit
Quit ← { •SH "stty"‿"-raw"‿"echo" ⋄ •Exit 𝕩}

# Fetch terminal width and height using `tput`
# Evaluate with •BQN to convert strings to integers
w←•BQN 1⊑•SH "tput"‿"cols"
h←•BQN 1⊑•SH "tput"‿"lines"

# Put terminal to raw mode, disable echo
•SH "stty"‿"raw"‿"-echo"

While 1‿{𝕤
  c←•GetChar @
  •OutRaw c
  Quit⍟{c='q'}@
}
