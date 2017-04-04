# iOS 10 Animation demo

**DotsAnimation sample** is a sequence of series of different, separate animations, created to demonstrate using iOS 10 Animations API, described in [the article](link to published article).

![Dots Animation Gif](https://d3uepj124s5rcx.cloudfront.net/items/3W0h3s233t3Y1U3u3p0h/framed-demo-animation.gif?v=ca389f87 "Dots Animation")

 #### Here are some of the things that you’ll find in the code
 
 * Creating of Animation Objects using custom timing functions:
    * Cubic Bézier curves;
    * New *UISpringTimingParameters* that allow manipulating the mass, stiffness, damping, and initial velocity parameters;
 * Adding new animation blocks to existing objects on the fly (take a look into *ViewController.startReversedDotsAnimation* method);
 * Adding completion action on the fly (it's used to begin new animations phase, when the third dot is finishing its last jump);
 * Other possibilities of working with *UIViewPropertyAnimator* objects.
 
 #### Backward compatibility

Just like any new API in iOS, these new animations features don’t have backward compatibility. Make sure to use [#available](https://www.hackingwithswift.com/new-syntax-swift-2-availability-checking) operator to create a fallback solution.




