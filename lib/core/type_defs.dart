import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/failure.dart';


//Wer are using this for handling error this FutureEither class tells us that the return type can be of Either a failure in case an error occurs or anything when there is a success.
typedef FutureEither<T> = Future<Either<Failure, T>>;

//Now this here tells us that case of success we can se send void also.
typedef FutureVoid = FutureEither<void>;