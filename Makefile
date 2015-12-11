build:
	- rm -r lib
	coffee -o lib -c src
	echo "#! /usr/bin/env node" > lib/program.js
	cat lib/pm2-meteor.js >> lib/program.js
