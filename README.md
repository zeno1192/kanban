# clasroom ToDo

Flutter で作ったタスクボードです。

## GitHub Pages で公開する

リポジトリの Settings → Pages で、公開元を `gh-pages` ブランチの `/ (root)` に設定します。`main` のルートを選ぶと、この README が公開されます。

```sh
flutter build web --base-href /kanban/
touch build/web/.nojekyll
dart pub global run github_pages:github_pages -d build/web --dotfiles --repo https://github.com/zeno1192/kanban.git
```
