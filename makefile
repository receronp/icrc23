.PHONY: test docs actor-test

dfx-cache-install: 
	dfx cache install

test: dfx-cache-install
	$(shell mocv bin current)/moc -r $(shell mops sources) -wasi-system-api ./tests/**/**.Test.mo

no-warn: dfx-cache-install
	find src -type f -name '*.mo' -print0 | xargs -0 $(shell mocv bin current)/moc -r $(shell mops sources) -Werror -wasi-system-api

docs:
	$(shell mocv bin current)/mo-doc
	$(shell mocv bin current)/mo-doc --format plain

actor-test: dfx-cache-install
	-dfx start --background
	dfx deploy test
	dfx ledger fabricate-cycles --canister test
	dfx canister call test run_tests

ref-test:
	-dfx start --background --clean
	IDENTITY=$$(dfx identity whoami); \
	echo $$IDENTITY; \
	cat icrc1-default-args.txt | xargs -0 dfx deploy icrc3 --identity $$IDENTITY --no-wallet --argument ; \
	CANISTER=$$(dfx canister id icrc3); \
	cd Dfnity-ICRC1-Reference && cargo run --bin runner -- -u http://127.0.0.1:4943 -c $$CANISTER -s ~/.config/dfx/identity/$$IDENTITY/identity.pem