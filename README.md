## LineServer

### How to use

* Clone this repo.

```
	$ git clone github.com	
```

* Run the build.sh script to bring in the necessary dependencies.

```
	$ bash build.sh
```

* Run the run.sh script with the absolute path of the file you wish to serve.

```
	$ bash run.sh "absolute/path/to/file.txt"
```

* Request a line number (starting at 1) from the local instance of your LineServer.

```
	$ curl http://localhost:9292/lines/<line number>
``` 

A valid response should look like this:

```
	{"line":"What an awesome LineServer implementation! We should totally hire him!\n"}
```

### How does your system work?

When I first read through this project, I immediately thought about just dumping the contents of a file in some in memory indexed set like an array or dictionary. This would lead to constant time access, however for really big files it could pretty easily consume all of the systems memory. It was clear at that point that I needed some kind of persistence. I also really wanted to avoid database dependencies. Here’s what I came up with:

**Pre-processing**

The system starts by saving name of the file in an environment variable, which is then passed to a FileProcessor object when our Sinatra instance starts up.

The FileProcessor performs the important pre-processing step of streaming the file into chunks (temp files) that each have a capacity of some specified number of lines. I found 1000 worked pretty well, but it could easily be changed to better fit the average file size of your use case.

Each of these chunks is then associated with a Chunk object, which holds reference to the temp file, the starting line number contained in the chunk, and the ending line number contained in the chunk.

Chunk objects are then placed in an array in a singleton object called ChunkedFile (I know I'm not a big singleton fan either but it worked here).

**Request**

When a request is made to /lines/:line_number it is handled by a Sinatra route in the Api class.

The request then asks our singleton ChunkedFile object, which has maintained a count of the total lines in the file, if the line exists in the file. If it doesn't we just return a 413 status.

If the line does exist then the Api tells our ChunkedFile object to binary search through all of the Chunk objects and return the one that contains our line. Each Chunk contains the bounds of it's own temp file so no IO is required at this step.

Once the chunk is returned we re-open and stream through the chunks temp file to find our line and return it with a 200 status.

### How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file?

I wasn't really able to test with anything larger than a 738MB file because my computers disk is almost at capacity, but judging by the results it's pretty clear how the system would perform. 

Below is a graph of the results from my performance test:

![Performance Graph](https://github.com/johncosch/LineServer/blob/master/complexity_chart.png)

These results are pretty in-line with my assumptions. The request phase should execute in about logarithmic time. There are two important steps here. The first is the binary search, which executes in O(log(n/m)) time, where n is the total number of lines and m is the number of lines in the temp file. The second is streaming through the temp file for the correct line, which executes in constant time bounded above by the number of lines in the file or m. In our case this was 1000. Total execution time is then about O(log(n)).

Another important thing to consider with this implementation is that all IO is streamed which should conserve a significant amount of memory, and allow you to work with large files, or long lines without putting a strain on your system. 

The main resource used here is disk space, which is typically in much greater supply than memory.

### How will your system perform with 100 users? 10000 users? 1000000 users?

The system should perform well under most of these conditions. I didn't really load test the system much but, but based on the reasons above it should be pretty performant. My focus on memory utilization and the fact that only one line is allocated to memory at a time should allow for a large number of users on the system at one time. 

### What documentation, websites, papers, etc did you consult in doing this assignment?

- [Salsify's Engineering Blog](http://blog.salsify.com/engineering)
- [Salsify's Offline Sort Gem](https://github.com/salsify/offline-sort)
- [Wikipedia External Sorting](https://en.wikipedia.org/wiki/External_sorting)
- [Ruby Docs](http://ruby-doc.org/)
- [Sinatra Docs](http://www.sinatrarb.com/)

The first few helped me think about the best approach for managing memory and chunking the file. 

### What third-party libraries or other tools does the system use? How did you choose each library or framework you used?

I intentionally kept the dependencies at a minimum, but the tools I did utilize are:

**Sinatra / Sinatra-contrib:**
I used Sinatra to serve as my web framework. I did this because the scope of the project did not require something more robust like Rails. It allowed me to keep the the project simple, and totally modular.

**Puma:** 
I used Puma as my app server. Honestly Puma was a given because the Salsify team uses it in production. I have used it in the past, and loved the power and simplicity of it, so there's a good chance I would have went with it again even if I didn't know what Salsify used.  

**Rspec:** 
The best test suite around. How could I live without it?

**Rack-test:**
Used for integration testing with Sinatra.

**Ruby-Prof:**
A simple to use profiler for ruby, which allowed me to check that my algorithm was functioning correctly.

### How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?

I did the project somewhat sporadically over a period of a few days. All in all I would say writing, refactoring, performance testing, and packaging took me about 12 - 14 hours plus maybe another hour thinking about the problem. 

The first thing I would do is more performance and load testing. I would have to deploy to a remote server to test with large files, which is why it hasn't been done yet (my computer's a wimp).

The next thing I would do is look more closely at the performance of temp files. I suspect I could enhance upload time by using regular files rather than temp files by avoiding potential name collisions. Also, temp files are removed on reboot which could potentially lead to some errors. 

Aside from that there is a lot of error handling and general clean up that needs to be done still. 

### If you were to critique your code, what would you have to say about it?

Overall I'm pretty pleased with the implementation from a performance standpoint. I also think the structure is pretty clear, but it could certainly be cleaned up to allow for more extension in the future. My tests could really use some DRYing up, but they get the job done for the time being. It's no where near perfect, but I think it's a great start! 
