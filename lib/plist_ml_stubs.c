// -*- objc -*-

#define CAML_NAME_SPACE

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/custom.h>
#import <caml/threads.h>

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

  // NSString *s = [[NSString alloc] initWithUTF8String:String_val(str)];
  // NSData *d = [NSJSONSerialization dataWithJSONObject:s options:0 error:nil];
  NSData *s1 = [NSData dataWithBytes:String_val(str) length:caml_string_length(str)];
  NSMutableDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:s1
				    options:NSJSONReadingMutableContainers
				      error:nil];
  // NSLog(@"test: %@", dict);
  wrapper = caml_alloc_custom(&nsdict_custom_ops, sizeof(id), 0, 1);
  memcpy(Data_custom_val(wrapper), &dict, sizeof(id));
  // NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:(nonnull NSString *)]
  CAMLreturn(wrapper);
}

CAMLprim value
plist_ml_to_file(value filename, value plist_dict)
{
  CAMLparam2(filename, plist_dict);
  NSMutableDictionary *d = NSDict(plist_dict);
  caml_acquire_runtime_system();
  [d writeToFile:@(String_val(filename)) atomically:YES];
  caml_release_runtime_system();
  CAMLreturn(Val_unit);
}

CAMLprim value
plist_ml_to_string(value plist_dict)
{
  CAMLparam1(plist_dict);
  CAMLlocal1(ml_string);
  NSMutableDictionary *d = NSDict(plist_dict);
  NSData *dump = [NSJSONSerialization dataWithJSONObject:d
						 options:NSJSONWritingPrettyPrinted
						   error:nil];
  NSString *s = [[NSString alloc] initWithData:dump encoding:NSUTF8StringEncoding];
  const size_t length = [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

  ml_string = caml_alloc_string(length);
  memmove(String_val(ml_string), [s UTF8String], length);
  [dump release];
  [s release];
  CAMLreturn(ml_string);
}

// CAMLprim value
