## TouchRSS

### Introduction to TouchRSS

#### Description
TouchRSS is a general purpose RSS and Atom reading framework. It incorporates local caching and cache management and will automatically manage the feed fetch interval to avoid excessive server load.

#### Requirements

TouchRSS depends on other Touchcode projects. You'll need to add these to your project in order to use TouchRSS:

* [TouchXML](https://github.com/touchcode/TouchXML), for XML processing
* [TouchFoundation](https://github.com/touchcode/TouchFoundation), for a variety of purposes including network connections, Core Data management, data encoding, and others.

#### Adding TouchRSS to your project

1. Download the TouchRSS source code and add all files from the "Source" directory to your project. Do the same for TouchFoundation and TouchXML. _TouchRSS doesn't actually need everything in TouchFoundation but optimizing file inclusion is left as an exercise for the reader._
1. Add libxml to the target. Do this by adding "-lxml2" in the "Other Linker Flags" section of the target settings, and /usr/include/libxml2 to the "Header Search Paths" section.
1. Add CFNetwork.framework and CoreData.framework to the target. _TouchRSS uses Core Data for cache management, so add CoreData.framework even if you're not using Core Data yourself._

#### Using TouchRSS

1. Initialize a CFeed object for your feed.

        CFeed *feed = [[CFeedStore instance] feedForURL:[NSURL URLWithString:FEED_URL] fetch:YES];

1. If you have previously loaded articles from the CFeed created above, cached articles from the previous load will be immediately available as CFeedEntry objects via the feed's `elements` property. To get the articles sorted in the order they appeared in the feed, sort the articles using the `fetchOrder` property:

        NSArray *entries = [[feed entries] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fetchOrder" ascending:YES]]];

1. To update feeds, create a CFeedFetcher and subscribe to the feed URL:

        CFeedFetcher *feedFetcher = [[CFeedFetcher alloc] initWithFeedStore:[CFeedStore instance]];
        [feedFetcher setDelegate:self];
        NSError *error = nil;
        [feedFetcher subscribeToURL:[NSURL URLWithString:FEED_URL] error:&error];

1. (Optional) Set a custom fetch interval on the CFeedFetcher. The CFeedFetcher will ignore requests to update the feed if fewer than `fetchInterval` second have passed since the previous update. If you don't set a fetch interval, the default is 300 seconds.

        [feedFetcher setFetchInterval:600.0];

1. When the feed fetcher has loaded and cached new articles, it calls its delegate's `feedFetcher:didFetchFeed:` method. The `inFeed` argument is the same CFeed object created earlier. New articles will have been cached, and articles that are no longer in the feed's XML will have been removed from the cache. _CFeedFetcher has several other delegate methods, which you can find listed in CFeedFetcher.h_

        - (void)feedFetcher:(CFeedFetcher *)inFeedFetcher didFetchFeed:(CFeed *)inFeed
        {
            NSLog(@"Fetcher fetched feed %@", inFeed);
            NSLog(@"New entries: %@", [inFeed entries]);
        }
