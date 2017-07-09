# Galaxy Editor
![alt text](https://raw.githubusercontent.com/papplication/galaxy-editor/master/assets/example.gif "GE iOS simulation")

## Summary

A simple tool to create pixelated objects with unique physics. It provides a protocol which can handle these specific objects in your own iOS app. The app written in Swift for OSX.

![alt text](https://raw.githubusercontent.com/papplication/galaxy-editor/master/assets/GEimage.png "GE app image")
## Features

* GEObject simulation
* Reference node selector
* Import objects
* Export objects
* Drag and drop files
* Color picker
* Help

## Examples
According to the GEExampleApp you can find a reference implementation. There is a simple test enverionment too where you can try the physics simulation in real time. The example app written in Swift for iOS.

## Usage
Draw something, then copy the **common** directory into your project. Put your GEObject into the SKScene.

### GEObject
Main object which represents a single node. There are two parameters for initialization, a file path and a boolean value for simulation.
	
```
init(path:String, hasPhysics:Bool)
```

**Reference node:** This is a very important node because the rest of the nodes' position are compared to this one. The first node is by default, but you can change it later. The reference node is the parent of the others.

GEObject format:
```json
{
  "scale" : 0.05444998294115067,
  "nodes" : [
    [
      {
        "id" : 1
      },
      {
        "posX" : 460.799987792969
      },
      {
        "posY" : 358.399963378906
      },
      {
        "color" : "#FFFFFF"
      }
    ],
    [
      {
        "id" : 2
      },
      {
        "posX" : 0
      },
      {
        "posY" : 12.7998962402344
      },
      {
        "color" : "#FF0033"
      }
    ]
  ]
}
```

### GEOPhysics
Modify your SKScene like this:
	
```
func didBeginContact(contact: SKPhysicsContact) {
    GEOPhysics.didBeginContact(contact)
}
```
GEObject contact category is **GEObjectCategory**, if you want to interacting whith them use **ContactTestCategory** in other SKSpriteNode.

### Limitations
The current implementation performance depends on node count. The performance issues appeared when numerous children nodes were added (approximately 3-400/parent), as a consequence the fps dropped significantly. Keep the number of child nodes as low as you can.

## Changelog
### Version 1.1
* Example iOS app added - tested on iPhone 6

## About
**P'application Studio** 	- http://papplication.tumblr.com

**Twitter**					- https://twitter.com/P_application