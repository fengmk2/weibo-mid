TESTS = test/*.test.js
REPORTER = spec
TIMEOUT = 1000
MOCHA_OPTS =
COMPONENT = ./node_modules/.bin/component

build: components index.js lib/*.js
	@$(COMPONENT) build --dev

components: component.json
	@$(COMPONENT) install --dev

clean:
	@rm -rf components build

install:
	@npm install

test: install
	@NODE_ENV=test ./node_modules/mocha/bin/mocha \
		--reporter $(REPORTER) \
		--timeout $(TIMEOUT) \
		$(MOCHA_OPTS) \
		$(TESTS)

test-cov:
	@rm -f coverage.html
	@$(MAKE) test MOCHA_OPTS='--require blanket' REPORTER=html-cov > coverage.html
	@$(MAKE) test MOCHA_OPTS='--require blanket' REPORTER=travis-cov
	@ls -lh coverage.html

test-coveralls: test test-component
	@echo TRAVIS_JOB_ID $(TRAVIS_JOB_ID)
	@-$(MAKE) test MOCHA_OPTS='--require blanket' REPORTER=mocha-lcov-reporter | ./node_modules/coveralls/bin/coveralls.js

test-component: build
	@./node_modules/.bin/mocha-phantomjs test/test.html

test-browser: build
	@open test/test.html

test-all: test test-cov

.PHONY: install test test-cov test-all test-coveralls
