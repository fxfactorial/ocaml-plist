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
  NSError *error = nil;
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

  NSData *s1 = [NSData dataWithBytes:String_val(str) length:caml_string_length(str)];
  NSMutableDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:s1
				    options:NSJSONReadingMutableContainers
				      error:&error];
  wrapper = caml_alloc_custom(&nsdict_custom_ops, sizeof(id), 0, 1);
  // We need to hold onto the NSMutableDictionary
  [dict retain];
  memcpy(Data_custom_val(wrapper), &dict, sizeof(id));
  [myPool drain];
  CAMLreturn(wrapper);
}

CAMLprim value
plist_ml_to_file(value filename, value plist_dict)
{
  CAMLparam2(filename, plist_dict);
  NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *d = NSDict(plist_dict);
  NSString *filepath =
    [[NSString alloc] initWithBytes:String_val(filename)
			     length:caml_string_length(filename)
			   encoding:NSUTF8StringEncoding];

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
  NSData *dump = [NSJSONSerialization dataWithJSONObject:d
						 options:NSJSONWritingPrettyPrinted
						   error:&error];
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
