# Everything::Wordpress

This is a script to read a post from an `everything` repo and publish it to a
WordPress blog.

## Install

Once you have the source locally, install the needed gems.

`bundle install --path=.bundle`

## Setup

There are four required environment variables. You can store them in a `.env`
file, which will be automatically loaded when this application runs.

- `EVERYTHING_PATH` - local path to your `everything` repo
- `EVERYTHING_WORDPRESS_PATH` - local path to your `everything-wordpress` repo
- `WORDPRESS_HOST` - URL of your WordPress blog, without a protocol
- `WORDPRESS_USERNAME`
- `WORDPRESS_PASSWORD`

Be sure the WordPress blog has the `WP-Markdown` plugin installed, so it can
render a Markdown post properly.

Since this requires an `everything` repo, we expect that there's a directory
for the post. The directory's name will be be the command line argument to
this application.

This directory must then also have an `index.md` and an `index.yaml` within it.

- `index.md` is the post's content, written in Markdown.
  - The first line must be the blog's title in the format: `# Blog Title Here`
  - The second line must be empty
  - The third line through the end is the content for the post.
- `index.yaml` is the post's metadata, written in YAML
  - In order to publish the post, it must have a `public` key with a value of `true`.
  - You must also have a YAML sequence (array) of categories. There must be at
    least one category.

We also require an `everything-wordpress` repo, for maintaining metadata about
the posts when they get published. Right now, this is used to keep track of
which posts you've published, so you can update them later.

## Advanced

To run the script from anywhere, we can modify the PATH to append the `bin`
directory and create an alias so that Bundler is used correctly.

If you use `zsh`, you can add this to your `.zshrc`:

```
export PATH=$PATH:/path/to/everything-wordpress/bin
alias bew="BUNDLE_GEMFILE=/path/to/everything-wordpress/Gemfile bundle exec ew ${@:2}"
```

## Publishing a Post

```
./ew publish <POST_PATH>
```

If this post is new, you'll see some text that it was succesfully posted.
If the post already exists, you'll see some text saying it was successfully
updated.

## Notes

Right now, there are some limitations:

- Categories are still pulled from the `everything` repo instead of the
  `everything-wordpress` repo like they should be.

## License

MIT

