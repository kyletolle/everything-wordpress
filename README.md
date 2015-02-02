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
- `WORDPRESS_HOST` - URL of your WordPress blog, without a protocol
- `WORDPRESS_USERNAME`
- `WORDPRESS_PASSWORD`

Be sure the WordPress blog has the `WP-Markdown` plugin installed, so it can
render a Markdown post properly.

Since this requires an `everything` repo, we expect that there's a directory
for the post that has a name and an `index.md` and an `index.yaml` under it.

`index.md` is the post's content, written in Markdown.
`index.yaml` is the post's metadata, written in YAML, which must have a
`public` key with a value of `true` to indicate this post should be published.

The directory's name is what will be be the command line argument to this
application, and serves as the blog post's title.

## Publishing a Post

```
./ew publish <POST_PATH>
```

If all goes well, you'll see some text mentioning the blog post's ID.

## Notes

Right now, there are some limitations:

- Categories for the post are hardcoded.
- Publishing the same post a second time creates a duplicate blog post.
- There's no updating a post once it's been published.
- Titles are based on the post's path which is passed in, instead of the content itself.

