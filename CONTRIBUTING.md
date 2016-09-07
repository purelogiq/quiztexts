### Starting off

- Make sure you have a functioning rails development environment
- FlashTxts uses Rails 5, read up on the differences between Rails 4 and Rails 5 [here](http://nithinbekal.com/posts/rails-5-features/). It's not too different.
- Clone the repo using `git clone git@github.com:purelogiq/flashtxts.git`
- Monitor the Slack channel.

### How to make regular changes

- Run `git checkout master` to checkout the master branch. The master branch is only for code that is 100% good to go and has been reviewed via pull requests.
- Every day run `git pull` to pull all the new changes. 
- When starting on a new change make a new branch for that change with `git checkout -b initials/my-new-branch`, give it a good name replace 'initials' with your initials, e.g. `git checkout -b plq/add-navigation-menu`.
- Make your changes in the rails app, write unit tests and functional tests.
- Every now and then run `rails test` to test your changes. Run `rails server` and test out your changes in a browser if possible.
- Run `git status` to see the files you changed. Run `git diff` (move up and down with j and k, q to quit) to see the changes you made in each file.
- `git add` the files that you are positive are good to go. Then `git commit -m "My useful commit message`.
- `git push origin -u initials/my-new-branch` to push your branch to this GitHub repo. (Do this as often as possible so you always have a backup).
- IMPORTANT: if it has been a while since you made changes compared to the master branch run `git rebase master` to update your current branch with the changes that happened on the master branch. This is prefered over doing `git merge master`, but, use whichever you are most comfortable with. Fix any merge conflicts that arise.
- Go to the GitHub website here and make a pull request to merge your branch into the master branch.
- Make sure TravisCI and HoundCI pass on your pull request. Fix whatever problems HoundCI tells you to.

### How to test your changes on the production server

We have a "production" server, but, it is **totally ok** to test things that can break. 
Now when you are working on your code and you want to deploy it to test it out do the following steps:

1. Commit your changes in your branch.
2. Push your changes to GitHub.
3. If you have migrations make sure that `rails db:migrate` and `rails server` work fine on your machine.
4. Tell everyone else in the Slack channel that you are about to do a deploy and how long you will need the server for to test your changes.
5. Make sure you are in the rails app directory then run `cap production deploy`
6. Read the questions that follow and answer yes or no appropriately
7. Let the script finish then go to flashtxts.com to checkout your changes (or text the number to checkout the updated code).

**IF YOU BREAK THE PRODUCTION SERVER** - it's ok. Just `git checkout master` then deploy it following the same steps above. Remember the master branch is (almost) guareenteed to work. If things still aren't working like before tell the team in the Slack channel. 

### Communicate

- Talk about ideas you have or things that you think could be improved.
- If you need help with some code let someone know. This is a team effort.
- Write good pull request messages that you would be proud to display on your public GitHub profile.
- Make sure to let others know when and how long you will need to test on the production server.
