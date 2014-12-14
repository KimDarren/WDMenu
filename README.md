# WDMenu

**WDMenu** is simple menu view with some animation for iOS.

###Screenshots
- Before open the menu.
![Screenshot01](https://github.com/KimDarren/WDMenu/blob/master/Screenshots/01.PNG)
- After open the menu.
![Screenshot02](https://github.com/KimDarren/WDMenu/blob/master/Screenshots/02.PNG)

### How to use.

```
WDMenu *menu = [[WDMenu alloc] initWithContentsView:contentsView superView:self.view height:62.0f buttonImage:buttonImage];
```

### Customizing.

- Set animation duration
```
menu.animationDuration = 5.0f;
```
- Set background color
```
menu.backgroundColor = [UIColor redColor];
```

### Todo's

- Make codes more beautiful.

License
----

MIT