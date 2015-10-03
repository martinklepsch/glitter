```
          .---.                                                   
          |   |.--.                        __.....__              
  .--./)  |   ||__|                    .-''         '.            
 /.''\\   |   |.--.     .|       .|   /     .-''"'-.  `. .-,.--.  
| |  | |  |   ||  |   .' |_    .' |_ /     /________\   \|  .-. | 
 \`-' /   |   ||  | .'     | .'     ||                  || |  | | 
 /("'`    |   ||  |'--.  .-''--.  .-'\    .-------------'| |  | | 
 \ '---.  |   ||  |   |  |     |  |   \    '-.____...---.| |  '-  
  /'""'.\ |   ||__|   |  |     |  |    `.             .' | |      
 ||     ||'---'       |  '.'   |  '.'    `''-...... -'   | |      
 \'. __//             |   /    |   /                     |_|      
  `'---'              `'-'     `'-'                               
```

Glitter is a little command line tool to create users, access keys and
S3 buckets for static site projects.

---

### Usage

It's really simple, either you create a new project or you roll back
changes (i.e. delete it). Make sure you have [awscli][awscli] installed.

```
glitter --new your-fancy-project
```

```
glitter --rollback your-fancy-project.glitter
```

---

### Contributing

Glitter is written in about 500 lines of Racket and relies on `aws`
([awscli][awscli]) being present in your `$PATH`.  I used it as a
playground project for Racket and over time I got to the conclusion
that abstracting over a shell script is not such a great idea. I liked
that you can make standalone executables with Racket but since
[awscli][awscli] is required it's less useful.

That said I'll try to use it for my stuff. If it becomes to
frustrating maybe I'll port things to Clojure.

---

### License

MIT
