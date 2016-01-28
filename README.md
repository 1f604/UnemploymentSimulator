# UnemploymentSimulator

Unemployment simulator. Written in CoffeeScript and HTML5. Most of the code 
was copied from Volkhin's Road Traffic Simulator. My code is probably <1%
of the total, lol. This project probably took me 20-50 hours altogether 
including trying to learn CoffeeScript. I still have next to no idea how to
write CoffeeScript so expect to see some stupid things in the code. 

Currently it only simulates a single lane (i.e everyone treated the same, 
first come first get employed) but it was originally planned to allow for 
multiple segments of the population (e.g based on gender, race etc) to be 
placed in separate lanes so they can be modelled separately, each with its 
own set of variables (unemploymentrate, birthrate, jobgrowthrate, etc). 
I probably won't implement that feature anytime soon if ever. 

Also there is a problem where the cars clump together and overlap in space. 
The cars actually do not maintain a consistent distance between one another
when stopped which I think is a problem from the original simulator. 
It seems to be somewhat random. I don't know how to fix it. 

Also I didn't bother changing the tests so a lot of it is probably not 
applicable to this project. 

## Demo
#insert URL of demo here

* Mouse and wheel - scrolling and zoom
* For a change in the poplimit to take effect you must press generateMap. 
* Changes in the other variables should take effect instantly. 
* Press displayInfo for some info to be logged to the console. 

## Contributing
Feel free to send pull requests and create bug reports/feature requests 
using issues though I probably won't respond. 

To run simulator

    git clone https://github.com/1f604/UnemploymentSimulator
    cd UnemploymentSimulator
    npm install

And open index.html in your browser. Use **gulp** to rebuild project.