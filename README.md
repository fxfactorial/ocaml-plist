

Good idea that will work on Linux and OS X is
to use 

	// [[NSDictionary alloc] initWithContentsOfFile:(nonnull NSString *)
and 

where d == NSDictionary

	[d writeToFile:@"test.txt" atomically:YES];

and on Linux just use openstep
