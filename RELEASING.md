Releasing
=========

 1. Verify everything works with `make test build`.
 2. Bump version in [`version.rb`](https://github.com/itskoko/koko-ai-ruby/blob/master/lib/koko/version.rb).
 3. Update [`History.md`](https://github.com/itskoko/koko-ai-ruby/blob/master/History.md).
 4. Commit and tag `git commit -am "Release {version}" && git tag -a {version} -m "Version {version}"`.
 5. Build the gem with the tagged version `make build`.
 6. Upload to RubyGems with `gem push koko-ai-{version}.gem`.
 7. Upload to Github with `git push -u origin master && git push --tags`.
