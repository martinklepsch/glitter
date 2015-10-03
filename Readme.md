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

Glitter is a shitty wrapper around [awscli][awscli] to create users,
access keys, inline policies and S3 buckets for static site projects.

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

The `glitter` binary can be compiled with `raco exe -o glitter src/glitter.rkt`.

### Demo

[![asciicast](https://asciinema.org/a/061hvmro87di7k74gbkz15eqx.png)](https://asciinema.org/a/061hvmro87di7k74gbkz15eqx)

### Contributing

Glitter is written in about 500 lines of Racket and relies on `aws`
([awscli][awscli]) being present in your `$PATH`.  I used it as a
playground project for Racket and over time got to the conclusion that
abstracting over shell scripts is not such a great idea. I liked that
you can make standalone executables with Racket but since
[awscli][awscli] is required it's not fully standalone anyways.

That said I'll try to use it for my stuff. If it becomes too
frustrating maybe I'll port things to Clojure.

Some things that should be added but I probably won't do:

- Cloudfront Distribution setup
- Route 53 setup

---

### License

MIT

[awscli]: https://aws.amazon.com/de/cli/
