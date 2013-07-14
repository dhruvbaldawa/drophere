deploy:
	git branch -D deploy ||\
	git checkout --orphan deploy &&\
	coffee -c lib/config.coffee &&\
	git add -f lib/config.js &&\
	git commit -m 'Initial deploy' &&\
	git push -f deploy deploy:master &&\
	git checkout master
