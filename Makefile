deploy:
	git branch -D deploy
	git checkout --orphan deploy
	git add -f config.js
	git push -f deploy deploy:master
