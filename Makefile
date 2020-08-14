fzel.emacs:
	emacs --batch \
	--load /home/russell/projects/fzel/fzel-init.el \
	--execute "(dump-emacs-portable \"fzel\")"

clean:
	rm fzel.emacs
