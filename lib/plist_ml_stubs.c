// -*- objc -*-

#define CAML_NAME_SPACE

#import <Foundation/Foundation.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/custom.h>
#import <caml/threads.h>
#import <caml/fail.h>

#define NSDict(v) (*(NSMutableDictionary**)Data_custom_val(v))

void release_nsdict(value this_dict)
{
  [NSDict(this_dict) release];
}

long nsdict_hash(value this_dict)
{
  return [NSDict(this_dict) hash];
}

static struct custom_operations nsdict_custom_ops = {
  .identifier = "com.hyegar.plist",
  .finalize = release_nsdict,
  .compare = NULL,
  .hash = nsdict_hash,
  .serialize = NULL,
  .deserialize = NULL
};

CAMLprim value
plist_ml_from_string(value str)
{
  CAMLparam1(str);
  CAMLlocal1(wrapper);
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

  NSError *error = nil;
  NSData *s1 = [NSData dataWithBytes:String_val(str) length:caml_string_length(str)];
  NSMutableDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:s1
				    options:NSJSONReadingMutableContainers
				      error:&error];
  if (error) {
    const char *e_message = [[error localizedDescription] UTF8String];
    [myPool drain];
    caml_invalid_argument(e_message);
  }
  wrapper = caml_alloc_custom(&nsdict_custom_ops, sizeof(id), 0, 1);
  // We need to hold onto the NSMutableDictionary
  [dict retain];
  memcpy(Data_custom_val(wrapper), &dict, sizeof(id));
  [myPool drain];
  CAMLreturn(wrapper);
}

CAMLprim value
plist_ml_to_file(value filename, value as_binary, value plist_dict)
{
  CAMLparam3(filename, as_binary, plist_dict);
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

  NSError *error = nil;
  id d = NSDict(plist_dict);
  NSString *filepath =
    [[NSString alloc] initWithBytes:String_val(filename)
			     length:caml_string_length(filename)
			   encoding:NSUTF8StringEncoding];

  if (Bool_val(as_binary)) {
    d = [NSPropertyListSerialization
	  dataWithPropertyList:d
			format:NSPropertyListBinaryFormat_v1_0
		       options:0
			 error:&error];
    if (error) {
      const char *e_message = [[error localizedDescription] UTF8String];
      [myPool drain];
      caml_invalid_argument(e_message);
    }

  }

  caml_release_runtime_system();
  [d writeToFile:filepath atomically:YES];
  caml_acquire_runtime_system();

  [myPool drain];
  CAMLreturn(Val_unit);
}

CAMLprim value
plist_ml_to_string(value plist_dict)
{
  CAMLparam1(plist_dict);
  CAMLlocal1(ml_string);
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *d = NSDict(plist_dict);
  NSError *error = nil;
  NSData *dump =
    [NSJSONSerialization dataWithJSONObject:d
				    options:NSJSONWritingPrettyPrinted
				      error:&error];
  if (error) {
    const char *e_message = [[error localizedDescription] UTF8String];
    [myPool drain];
    caml_invalid_argument(e_message);
  }

  NSString *s = [[NSString alloc] initWithData:dump encoding:NSUTF8StringEncoding];
  const size_t length = [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

  ml_string = caml_alloc_string(length);
  memmove(String_val(ml_string), [s UTF8String], length);
  [myPool drain];
  CAMLreturn(ml_string);
}

CAMLprim value
plist_ml_from_file(value filename)
{
  CAMLparam1(filename);
  CAMLlocal1(plist);
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

  NSString *file_path =
    [[NSString alloc] initWithBytes:String_val(filename)
			     length:caml_string_length(filename)
			   encoding:NSUTF8StringEncoding];
  BOOL file_exists = [[NSFileManager defaultManager] fileExistsAtPath:file_path];
  if (file_exists == NO) caml_invalid_argument("File does not exist");

  caml_release_runtime_system();
  id p = [[NSDictionary alloc] initWithContentsOfFile:file_path];
  caml_acquire_runtime_system();

  plist = caml_alloc_custom(&nsdict_custom_ops, sizeof(id), 0, 1);
  memcpy(Data_custom_val(plist), &p, sizeof(id));
  // Hold onto the Dict
  [p retain];
  [myPool drain];
  CAMLreturn(plist);
}

CAMLprim value
plist_ml_to_bytes(value plist)
{
  CAMLparam1(plist);
  CAMLlocal1(raw_bytes);
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
  NSError *error = nil;

  NSData *d = [NSPropertyListSerialization
		dataWithPropertyList:NSDict(plist)
			      format:NSPropertyListBinaryFormat_v1_0
			     options:0
			       error:&error];
  if (error) {
    const char *e_message = [[error localizedDescription] UTF8String];
    [myPool drain];
    caml_invalid_argument(e_message);
  }

  raw_bytes = caml_alloc_string([d length]);
  memcpy(String_val(raw_bytes), [d bytes], [d length]);
  [myPool drain];
  CAMLreturn(raw_bytes);
}
