( function _WillInternals_test_s_( ) {

'use strict';

/*

!!! add test routine openning out-will-file

*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );;
  _.include( 'wExternalFundamentals' );
  _.include( 'wFiles' );

  require( '../will/MainBase.s' );

}

var _global = _global_;
var _ = _global_.wTools;

//

function onSuiteBegin()
{
  let self = this;

  self.tempDir = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'Will' );
  self.assetDirPath = _.path.join( __dirname, 'asset' );
  self.find = _.fileProvider.filesFinder
  ({
    recursive : 2,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    outputFormat : 'relative',
  });

}

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.tempDir, '/dwtools/tmp.tmp' ) )
  _.fileProvider.filesDelete( self.tempDir );
}

// --
// tests
// --

function buildSimple( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'simple' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, '.' );
  let modulesPath = _.path.join( routinePath, '.module' );
  let exportPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesDelete( exportPath );

  var module = will.moduleMake({ filePath : modulePath });

  return module.ready.split().then( () =>
  {

    var expected = [];
    var files = self.find( exportPath );

    let builds = module.buildsSelect();

    test.identical( builds.length, 1 );

    let build = builds[ 0 ];

    return build.perform()
    .finally( ( err, arg ) =>
    {

      var expected = [ '.', './debug', './debug/File.js' ];
      var files = self.find( exportPath );
      test.identical( files, expected );

      module.finit();
      if( err )
      throw err;
      return arg;
    });

  });
}

buildSimple.timeOut = 30000;

//

function makeNamed( test )
{
  let self = this;
  let assetName = 'import-in/super';
  let originalDirPath = _.path.join( self.assetDirPath, 'import-in' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, 'super' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  var module1 = will.moduleMake({ filePath : modulePath });
  var module2 = will.moduleMake({ dirPath : modulePath });

  /* - */

  module1.ready.thenKeep( ( arg ) =>
  {
    debugger;
    test.case = 'opened filePath : ' + assetName;
    check( module1 );
    return null;
  })

  /* - */

  module1.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    module1.finit();
    if( err )
    throw err;
    return arg;
  });

  /* - */

  module2.ready.thenKeep( ( arg ) =>
  {
    debugger;
    test.case = 'opened dirPath : ' + assetName;
    check( module2 );
    return null;
  })

  /* - */

  module2.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    module2.finit();
    if( err )
    throw err;
    return arg;
  });

  return _.Consequence.AndTake([ module1.ready, module2.ready ])
  .finallyKeep( ( err, arg ) =>
  {
    debugger;
    if( err )
    throw err;
    return arg;
  });

  /* - */

  function check( module )
  {

    let pathMap =
    {
      'proto' : './proto',
      'temp' : './super.out',
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release'
    }

    test.identical( module.nickName, 'module::super' );
    test.identical( module.absoluteName, 'module::super' );
    test.identical( module.inPath, routinePath );
    test.identical( module.outPath, routinePath + '/super.out' );
    test.identical( module.dirPath, routinePath );
    test.identical( module.filePath, routinePath + '/super' );
    test.identical( module.configName, 'super' );

    test.is( !!module.about );
    test.identical( module.about.name, 'super' );
    test.is( !!module.execution );

    test.identical( module.pathMap, pathMap );
    test.identical( module.willFileArray.length, 2 );
    test.identical( _.mapKeys( module.willFileWithRoleMap ), [ 'import', 'export' ] );
    test.identical( _.mapKeys( module.submoduleMap ), [ 'MultipleExports' ] );
    test.identical( _.mapKeys( module.pathResourceMap ), [ 'proto', 'temp', 'in', 'out', 'out.debug', 'out.release' ] );
    test.identical( _.mapKeys( module.reflectorMap ), [ 'predefined.common', 'predefined.debug', 'predefined.release', 'reflect.submodules.', 'reflect.submodules.debug' ] );
    test.identical( _.mapKeys( module.stepMap ), [ 'predefined.delete', 'predefined.reflect', 'timelapse.begin', 'timelapse.end', 'predefined.js', 'predefined.shell', 'predefined.concat.js', 'submodules.download', 'submodules.upgrade', 'submodules.clean', 'clean', 'predefined.export', 'reflect.submodules.', 'reflect.submodules.debug', 'export.', 'export.debug' ] );
    test.identical( _.mapKeys( module.buildMap ), [ 'debug', 'release', 'export.', 'export.debug' ] );
    test.identical( _.mapKeys( module.exportedMap ), [] );

  }

}

makeNamed.timeOut = 30000;

//

function makeAnon( test )
{
  let self = this;
  let assetName = 'import-in/.';
  let originalDirPath = _.path.join( self.assetDirPath, 'import-in' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, '' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  var module1 = will.moduleMake({ filePath : modulePath });
  var module2 = will.moduleMake({ dirPath : modulePath });

  /* - */

  module1.ready.thenKeep( ( arg ) =>
  {
    debugger;
    test.case = 'opened filePath : ' + assetName;
    check( module1 );
    return null;
  })

  /* - */

  module1.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    module1.finit();
    if( err )
    throw err;
    return arg;
  });

  /* - */

  module2.ready.thenKeep( ( arg ) =>
  {
    debugger;
    test.case = 'opened dirPath : ' + assetName;
    check( module2 );
    return null;
  })

  /* - */

  module2.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    module2.finit();
    if( err )
    throw err;
    return arg;
  });


  return _.Consequence.AndTake([ module1.ready, module2.ready ])
  .finallyKeep( ( err, arg ) =>
  {
    debugger;
    if( err )
    throw err;
    return arg;
  });

  /* - */

  function check( module )
  {

    let pathMap =
    {
      'proto' : '.',
      'in' : 'proto',
      'out' : '../out',
      'out.debug' : '../out/debug',
      'out.release' : '../out/release'
    }

    test.identical( module.nickName, 'module::submodule' );
    test.identical( module.absoluteName, 'module::submodule' );
    test.identical( module.inPath, routinePath + '/proto' );
    test.identical( module.outPath, routinePath + '/out' );
    test.identical( module.dirPath, routinePath );
    test.identical( module.filePath, routinePath + '/' );
    test.identical( module.configName, 'makeAnon' );

    test.is( !!module.about );
    test.identical( module.about.name, 'submodule' );
    test.is( !!module.execution );

    test.identical( module.pathMap, pathMap );
    test.identical( module.willFileArray.length, 2 );
    test.identical( _.mapKeys( module.willFileWithRoleMap ), [ 'import', 'export' ] );
    test.identical( _.mapKeys( module.submoduleMap ), [] );
    test.identical( _.mapKeys( module.pathResourceMap ), [ 'proto', 'in', 'out', 'out.debug', 'out.release' ] );
    test.identical( _.mapKeys( module.reflectorMap ), [ 'predefined.common', 'predefined.debug', 'predefined.release', 'reflect.proto.', 'reflect.proto.debug' ] );
    test.identical( _.mapKeys( module.stepMap ), [ 'predefined.delete', 'predefined.reflect', 'timelapse.begin', 'timelapse.end', 'predefined.js', 'predefined.shell', 'predefined.concat.js', 'submodules.download', 'submodules.upgrade', 'submodules.clean', 'clean', 'predefined.export', 'reflect.proto.', 'reflect.proto.debug', 'reflect.proto.raw', 'reflect.proto.debug.raw', 'export.', 'export.debug' ] );
    test.identical( _.mapKeys( module.buildMap ), [ 'debug.raw', 'debug.compiled', 'release.raw', 'release.compiled', 'export.', 'export.debug' ] );
    test.identical( _.mapKeys( module.exportedMap ), [] );

  }

}

makeAnon.timeOut = 30000;

//

function makeOutNamed( test )
{
  let self = this;
  let assetName = 'import-in/super.out/super';
  let originalDirPath = _.path.join( self.assetDirPath, 'import-in' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let moduleDirPath = _.path.join( routinePath, 'super.out' );
  let moduleFilePath = _.path.join( routinePath, 'super.out/super' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  var module1 = will.moduleMake({ filePath : moduleFilePath });
  var module2 = will.moduleMake({ dirPath : moduleFilePath });

  /* - */

  module1.ready.thenKeep( ( arg ) =>
  {
    debugger;
    test.case = 'opened filePath : ' + assetName;
    check( module1 );
    return null;
  })

  /* - */

  module1.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.case = 'opened filePath : ' + assetName;
    test.is( err === undefined );
    module1.finit();
    if( err )
    throw err;
    return arg;
  });

  /* - */

  module2.ready.thenKeep( ( arg ) =>
  {
    debugger;
    test.case = 'opened dirPath : ' + assetName;
    check( module2 );
    return null;
  })

  /* - */

  module2.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.case = 'opened dirPath : ' + assetName;
    test.is( err === undefined );
    module2.finit();
    if( err )
    throw err;
    return arg;
  });

  return _.Consequence.AndTake([ module1.ready, module2.ready ])
  .finallyKeep( ( err, arg ) =>
  {
    debugger;
    if( err )
    throw err;
    return arg;
  });

  /* - */

  function check( module )
  {

    let pathMap =
    {
      'proto' : './proto',
      'temp' : './super.out',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release',
      'in' : '..',
      'exportedDir.export.debug' : './super.out/debug',
      'exportedFiles.export.debug' : [ 'super.out/debug', 'super.out/debug/File.debug.js', 'super.out/debug/File.release.js' ],
      'archiveFile.export.debug' : './super.out/super.debug.out.tgs',
      'exportedDir.export.' : './super.out/release',
      'exportedFiles.export.' : [ 'super.out/release', 'super.out/release/File.debug.js', 'super.out/release/File.release.js' ],
      'archiveFile.export.' : './super.out/super.out.tgs'
    }

    test.identical( module.nickName, 'module::super' );
    test.identical( module.absoluteName, 'module::super' );
    test.identical( module.inPath, routinePath );
    test.identical( module.outPath, routinePath + '/super.out' );
    test.identical( module.dirPath, routinePath + '/super.out' );
    test.identical( module.filePath, routinePath + '/super.out/super.out' );
    test.identical( module.configName, 'super.out' );

    test.is( !!module.about );
    test.identical( module.about.name, 'super' );
    test.is( !!module.execution );

    test.identical( module.pathMap, pathMap );
    test.identical( module.willFileArray.length, 1 );
    test.identical( _.mapKeys( module.willFileWithRoleMap ), [ 'single' ] );
    test.identical( _.mapKeys( module.submoduleMap ), [ 'MultipleExports' ] );
    test.identical( _.mapKeys( module.pathResourceMap ), [ 'proto', 'temp', 'in', 'out', 'out.debug', 'out.release', 'exportedDir.export.debug', 'exportedFiles.export.debug', 'archiveFile.export.debug', 'exportedDir.export.', 'exportedFiles.export.', 'archiveFile.export.' ] );
    test.identical( _.mapKeys( module.reflectorMap ), [ 'predefined.common', 'predefined.debug', 'predefined.release', 'reflect.submodules.', 'reflect.submodules.debug', 'exported.export.debug', 'exportedFiles.export.debug', 'exported.export.', 'exportedFiles.export.' ] );
    test.identical( _.mapKeys( module.stepMap ), [ 'predefined.delete', 'predefined.reflect', 'timelapse.begin', 'timelapse.end', 'predefined.js', 'predefined.shell', 'predefined.concat.js', 'submodules.download', 'submodules.upgrade', 'submodules.clean', 'clean', 'predefined.export', 'reflect.submodules.', 'reflect.submodules.debug', 'export.', 'export.debug' ] );
    test.identical( _.mapKeys( module.buildMap ), [ 'debug', 'release', 'export.', 'export.debug' ] );
    test.identical( _.mapKeys( module.exportedMap ), [ 'export.', 'export.debug' ] );

  }

}

makeOutNamed.timeOut = 30000;

//

function clone( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'import-in' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, 'super' );
  let modulesPath = _.path.join( routinePath, '.module' );
  let exportPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  function checkMap( mapName )
  {
    test.open( mapName );

    test.is( module[ mapName ] !== module2[ mapName ] );
    test.identical( _.mapKeys( module[ mapName ] ), _.mapKeys( module2[ mapName ] ) );
    for( var k in module[ mapName ] )
    {
      var resource1 = module[ mapName ][ k ];
      var resource2 = module2[ mapName ][ k ];
      test.is( !!resource1 );
      test.is( !!resource2 );
      if( !resource1 || !resource2 )
      continue;
      test.is( resource1 !== resource2 );
      test.is( resource1.module === module );
      test.is( resource2.module === module2 );
      if( resource1 instanceof will.Resource )
      {
        test.is( !!resource1.willf || ( resource1.criterion && resource1.criterion.predefined ) );
        test.is( !resource2.willf );
      }
    }

    test.close( mapName );
  }

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesDelete( exportPath );

  var module = will.moduleMake({ filePath : modulePath });
  var module2;

  /* - */

  module.ready.thenKeep( ( arg ) =>
  {
    test.case = 'clone';

    module2 = module.clone();

    test.case = 'compare elements';

    test.is( module.nickName === module2.nickName );
    test.is( module.absoluteName === module2.absoluteName );
    test.is( module.inPath === module2.inPath );
    test.is( module.outPath === module2.outPath );

    test.is( module.about !== module2.about );
    test.is( module.execution !== module2.execution );

    test.is( module.pathMap !== module2.pathMap );
    test.identical( module.pathMap, module2.pathMap );

    test.is( module.willFileArray !== module2.willFileArray );
    test.identical( module2.willFileArray, [] );

    test.is( module.willFileWithRoleMap !== module2.willFileWithRoleMap );
    test.identical( module2.willFileWithRoleMap, {} );

    checkMap( 'submoduleMap' );
    checkMap( 'pathResourceMap' );
    checkMap( 'reflectorMap' );
    checkMap( 'stepMap' );
    checkMap( 'buildMap' );
    checkMap( 'exportedMap' );

    test.case = 'finit';

    debugger;
    module2.finit();
    debugger;

    return null;
  })

  /* - */

  module.ready.finallyKeep( ( err, arg ) =>
  {
    debugger;
    test.is( err === undefined );
    module.finit();

    if( err )
    throw err;
    return arg;
  });
  return module.ready.split();
}

clone.timeOut = 130000;

//

function buildsResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'multiple-exports' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, 'super' );
  let modulesPath = _.path.join( routinePath, '.module' );
  let exportPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesDelete( exportPath );

  var module = will.moduleMake({ filePath : modulePath });

  /* - */

  module.ready.thenKeep( ( arg ) =>
  {

    test.case = 'build::*'; /* */

    var resolved = module.resolve({ selector : 'build::*' });
    test.identical( resolved.length, 4 );

    var expected = [ 'debug', 'release', 'export.', 'export.debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    var expected =
    [
      [ 'step::submodules.download', 'step::reflect.submodules.*=1' ],
      [ 'step::submodules.download', 'step::reflect.submodules.*=1' ],
      [ 'build::*=1', 'step::export*=1' ],
      [ 'build::*=1', 'step::export*=1' ]
    ];
    var got = _.select( resolved, '*/steps' );
    test.identical( got, expected );

    test.case = 'build::*, with criterion'; /* */

    var resolved = module.resolve({ selector : 'build::*', criterion : { debug : 1 } });
    test.identical( resolved.length, 2 );

    var expected = [ 'debug', 'export.debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    test.case = 'build::*, current is build::export.'; /* */

    var build = module.resolve({ selector : 'build::export.' });
    test.is( build instanceof will.Build );
    test.identical( build.nickName, 'build::export.' );
    test.identical( build.absoluteName, 'module::super / build::export.' );

    var resolved = module.resolve({ selector : 'build::*', current : build, singleUnwrapping : 0 });
    test.identical( resolved.length, 1 );

    var expected = [ 'release' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    var expected = { 'debug' : 0 };
    var got = resolved[ 0 ].criterion;
    test.identical( got, expected );

    test.case = 'build::*, current is build::export.debug'; /* */

    var build = module.resolve({ selector : 'build::export.debug' });
    var resolved = module.resolve({ selector : 'build::*', current : build, singleUnwrapping : 0 });
    test.identical( resolved.length, 1 );

    var expected = [ 'debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    var expected = { 'debug' : 1, 'default' : 1 };
    var got = resolved[ 0 ].criterion;
    test.identical( got, expected );

    test.case = 'build::*, current is build::export.debug, short-cut'; /* */

    var build = module.resolve({ selector : 'build::export.debug' });
    var resolved = build.resolve({ selector : 'build::*', singleUnwrapping : 0 });
    test.identical( resolved.length, 1 );

    var expected = [ 'debug' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    test.case = 'build::*, current is build::export.debug, short-cut, explicit criterion'; /* */

    var build = module.resolve({ selector : 'build::export.*', criterion : { debug : 1 } });
    var resolved = build.resolve({ selector : 'build::*', singleUnwrapping : 0, criterion : { debug : 0 } });
    test.identical( resolved.length, 2 );

    var expected = [ 'release', 'export.' ];
    var got = _.select( resolved, '*/name' );
    test.identical( got, expected );

    return null;
  })

  /* - */

  module.ready.finallyKeep( ( err, arg ) =>
  {

    debugger;
    test.is( err === undefined );
    module.finit();

    if( err )
    throw err;
    return arg;
  });
  return module.ready.split();
}

buildsResolve.timeOut = 130000;

//

function pathsResolve( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'multiple-exports' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, 'super' );
  let modulesPath = _.path.join( routinePath, '.module' );
  let exportPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  function pin( filePath )
  {
    return path.s.join( routinePath, filePath );
  }

  function pout( filePath )
  {
    return path.s.join( routinePath, 'super.out', filePath );
  }

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesDelete( exportPath );

  var module = will.moduleMake({ filePath : modulePath });

  /* - */

  module.ready.thenKeep( ( arg ) =>
  {

    test.case = 'resolved, .';
    var resolved = module.resolve({ prefixlessAction : 'resolved', selector : '.' })
    var expected = '.';
    test.identical( resolved, expected );

    return null;
  })

  module.ready.thenKeep( ( arg ) =>
  {

    test.case = 'path::in*=1, pathResolving : 0';
    var resolved = module.resolve({ prefixlessAction : 'resolved', selector : 'path::in*=1', pathResolving : 0 })
    var expected = '.';
    test.identical( resolved, expected );

    test.case = 'path::in*=1';
    var resolved = module.resolve({ prefixlessAction : 'resolved', selector : 'path::in*=1' })
    var expected = routinePath;
    test.identical( resolved, expected );

    return null;
  })

  /* - */

  module.ready.thenKeep( ( arg ) =>
  {

    test.case = 'path::* - implicit'; /* */
    var resolved = module.resolve( 'path::*' );
    test.identical( resolved.length, 6 );
    var expected = path.s.join( routinePath, [ './proto', './super.out', '.', './super.out', './super.out/debug', './super.out/release' ] );
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:1 pr:in'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 1,
      pathResolving : 'in',
    });
    test.identical( resolved.length, 6 );
    var expected = path.s.join( routinePath, [ './proto', './super.out', '.', './super.out', './super.out/debug', './super.out/release' ] );
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:1 pr:out'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 1,
      pathResolving : 'out',
    });
    test.identical( resolved.length, 6 );
    var expected = path.s.join( routinePath, 'super.out', [ './proto', './super.out', '.', '.', './super.out/debug', './super.out/release' ] );
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:1 pr:null'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 1,
      pathResolving : null,
    });
    test.identical( resolved.length, 6 );
    var expected = [ './proto', './super.out', '.', './super.out', './super.out/debug', './super.out/release' ];
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:0 pr:null'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 0,
      pathResolving : null,
    });
    var expected =
    {
      'proto' : './proto',
      'temp' : './super.out',
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release'
    }
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );
    _.any( resolved, ( e, k ) => test.is( e === module.pathResourceMap[ k ] ) );
    _.any( resolved, ( e, k ) => test.is( e.module === module ) );

    test.case = 'path::* - pu:0 mvu:0 pr:in'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 0,
      pathResolving : 'in',
    });
    var expected =
    {
      'proto' : pin( './proto' ),
      'temp' : pin( './super.out' ),
      'in' : pin( '.' ),
      'out' : pin( './super.out' ),
      'out.debug' : pin( './super.out/debug' ),
      'out.release' : pin( './super.out/release' ),
    }
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:0 pr:out'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 0,
      pathResolving : 'out',
    });
    var expected =
    {
      'proto' : pout( './proto' ),
      'temp' : pout( './super.out' ),
      'in' : pout( '.' ),
      'out' : pout( '.' ),
      'out.debug' : pout( './super.out/debug' ),
      'out.release' : pout( './super.out/release' ),
    }
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:0 pr:null'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 0,
      pathResolving : null,
    });
    var expected =
    {
      'proto' : './proto',
      'temp' : './super.out',
      'in' : '.',
      'out' : './super.out',
      'out.debug' : './super.out/debug',
      'out.release' : './super.out/release'
    }
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:0 pr:in'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 0,
      pathResolving : 'in',
    });
    var expected =
    {
      'proto' : pin( './proto' ),
      'temp' : pin( './super.out' ),
      'in' : pin( '.' ),
      'out' : pin( './super.out' ),
      'out.debug' : pin( './super.out/debug' ),
      'out.release' : pin( './super.out/release' ),
    }
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:1 mvu:0 pr:out'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 1,
      mapValsUnwrapping : 0,
      pathResolving : 'out',
    });
    var expected =
    {
      'proto' : pout( './proto' ),
      'temp' : pout( './super.out' ),
      'in' : pout( '.' ),
      'out' : pout( '.' ),
      'out.debug' : pout( './super.out/debug' ),
      'out.release' : pout( './super.out/release' ),
    }
    var got = resolved;
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:1 pr:null'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : null,
    });
    var expected = [ './proto', './super.out', '.', './super.out', './super.out/debug', './super.out/release' ];
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:1 pr:in'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : 'in',
    });
    var expected = pin([ './proto', './super.out', '.', './super.out', './super.out/debug', './super.out/release' ]);
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    test.case = 'path::* - pu:0 mvu:1 pr:out'; /* */
    var resolved = module.resolve
    ({
      selector : 'path::*',
      pathUnwrapping : 0,
      mapValsUnwrapping : 1,
      pathResolving : 'out',
    });
    var expected = pout([ './proto', './super.out', '.', '.', './super.out/debug', './super.out/release' ]);
    var got = _.select( resolved, '*/path' );
    test.identical( got, expected );

    return null;
  });

  /* - */

  module.ready.finallyKeep( ( err, arg ) =>
  {

    debugger;
    test.is( err === undefined );
    module.finit();

    if( err )
    throw err;
    return arg;
  });
  return module.ready.split();
}

pathsResolve.timeOut = 130000;

//

function pathsResolveImportIn( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'import-in' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, 'super' );
  let modulesPath = _.path.join( routinePath, '.module' );
  let exportPath = _.path.join( routinePath, 'out' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  function pin( filePath )
  {
    return path.s.join( routinePath, filePath );
  }

  function pout( filePath )
  {
    return path.s.join( routinePath, 'super.out', filePath );
  }

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });
  _.fileProvider.filesDelete( exportPath );

  var module = will.moduleMake({ filePath : modulePath });

  module.ready.thenKeep( ( arg ) =>
  {

    test.case = 'submodule::*/path::in*=1, default';
    var resolved = module.resolve( 'submodule::*/path::in*=1' )
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, pathResolving : 0';
    var resolved = module.resolve({ prefixlessAction : 'resolved', selector : 'submodule::*/path::in*=1', pathResolving : 0 })
    var expected = 'proto';
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, strange case';
    var resolved = module.resolve
    ({
      selector : 'submodule::*/path::in*=1',
      mapValsUnwrapping : 1,
      singleUnwrapping : 1,
      flattening : 1,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    // "submodule::*/exported::*=1/path::exportedDir*=1"

    return null;
  });

  module.ready.thenKeep( ( arg ) =>
  {

/*
  pathUnwrapping : 1,
  pathResolving : 0,
  flattening : 1,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
*/

    /* - */

    test.open( 'in' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = 'proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = 'proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ 'proto' ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/in' : 'proto' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : 'proto' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'in' : 'proto' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'in' : 'proto' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : 'proto' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';

    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ pin( 'proto' ) ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/in' : pin( 'proto' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'in' : pin( 'proto' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'in' : pin( 'proto' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'in' );

    /* - */

    test.open( 'proto' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '.';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ '.' ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/proto' : '.' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : '.' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'proto' : '.' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'proto' : '.' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : '.' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';

    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ pin( 'proto' ) ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/proto' : pin( 'proto' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'proto' : pin( 'proto' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'proto' : pin( 'proto' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'proto' );

    debugger;
    return null;
  })

  /* - */

  module.ready.finallyKeep( ( err, arg ) =>
  {

    debugger;
    test.is( err === undefined );
    module.finit();

    if( err )
    throw err;
    return arg;
  });
  return module.ready.split();
}

pathsResolveImportIn.timeOut = 130000;

//

function pathsResolveOutFileOfExports( test )
{
  let self = this;
  let originalDirPath = _.path.join( self.assetDirPath, 'multiple-exports-exported' );
  let routinePath = _.path.join( self.tempDir, test.name );
  let modulePath = _.path.join( routinePath, 'super.out/super' );
  let ready = new _.Consequence().take( null );
  let will = new _.Will;
  let path = _.fileProvider.path;

  function pin( filePath )
  {
    return path.s.join( routinePath, filePath );
  }

  function pout( filePath )
  {
    return path.s.join( routinePath, 'out', filePath );
  }

  _.fileProvider.filesDelete( routinePath );
  _.fileProvider.filesReflect({ reflectMap : { [ originalDirPath ] : routinePath } });

  var module = will.moduleMake({ filePath : modulePath });

  module.ready.thenKeep( ( arg ) =>
  {

    test.open( 'without export' );

    test.case = 'submodule::*/path::in*=1, default';
    var resolved = module.resolve( 'submodule::*/path::in*=1' )
    var expected = pin( '.' );
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, pathResolving : 0';
    var resolved = module.resolve({ prefixlessAction : 'resolved', selector : 'submodule::*/path::in*=1', pathResolving : 0 })
    var expected = '..';
    test.identical( resolved, expected );

    test.case = 'submodule::*/path::in*=1, strange case';
    var resolved = module.resolve
    ({
      selector : 'submodule::*/path::in*=1',
      mapValsUnwrapping : 1,
      singleUnwrapping : 1,
      flattening : 1,
    });
    var expected = pin( '.' );
    test.identical( resolved, expected );

    test.close( 'without export' );

    /* - */

    test.open( 'with export' );

    test.case = 'submodule::*/exported::*=1debug/path::in*=1, default';
    var resolved = module.resolve( 'submodule::*/exported::*=1debug/path::in*=1' );
    var expected = pin( '.' );
    test.identical( resolved, expected );

    test.case = 'submodule::*/exported::*=1debug/path::in*=1, pathResolving : 0';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/exported::*=1debug/path::in*=1',
      pathResolving : 0,
    })
    var expected = '..';
    test.identical( resolved, expected );

    test.case = 'submodule::*/exported::*=1debug/path::in*=1, strange case';
    var resolved = module.resolve
    ({
      selector : 'submodule::*/exported::*=1debug/path::in*=1',
      mapValsUnwrapping : 1,
      singleUnwrapping : 1,
      flattening : 1,
    });
    var expected = pin( '.' );
    test.identical( resolved, expected );

    test.close( 'with export' );

    // "submodule::*/exported::*=1debug/path::exportedDir*=1"

    return null;
  });

  module.ready.thenKeep( ( arg ) =>
  {

/*
  pathUnwrapping : 1,
  pathResolving : 0,
  flattening : 1,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
*/

    /* - */

    test.open( 'in' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = '..';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = '..';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ '..' ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/in' : '..' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : '..' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'in' : '..' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'in' : '..' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : '..' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';

    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pin( '.' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pin( '.' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ pin( '.' ) ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/in' : pin( '.' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : pin( '.' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'in' : pin( '.' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'in' : pin( '.' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::in*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::in*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'in' : pin( '.' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'in' );

    /* - */

    test.open( 'proto' );

    test.open( 'pathUnwrapping : 1' );

    test.open( 'pathResolving : 0' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = './proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = './proto';
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ './proto' ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/proto' : './proto' };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : './proto' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'proto' : './proto' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'proto' : './proto' } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 0,
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : './proto' }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : 0' );

    test.open( 'pathResolving : in' );

    test.open( 'flattening : 1' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';

    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );

    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = pin( 'proto' );
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = [ pin( 'proto' ) ];
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 1,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports/proto' : pin( 'proto' ) };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 1' );
    test.open( 'flattening : 0' );

    test.open( 'singleUnwrapping : 1' );

    test.open( 'mapValsUnwrapping : 1' );

    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 1,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 1,
      mapValsUnwrapping : 0,
    });
    var expected = { 'MultipleExports' : { 'proto' : pin( 'proto' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 1' );
    test.open( 'singleUnwrapping : 0' );

    test.open( 'mapValsUnwrapping : 1' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 1,
    });
    var expected = { 'MultipleExports' : { 'proto' : pin( 'proto' ) } };
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 1' );
    test.open( 'mapValsUnwrapping : 0' );
    test.case = 'submodule::*/path::proto*=1';
    var resolved = module.resolve
    ({
      prefixlessAction : 'resolved',
      selector : 'submodule::*/path::proto*=1',
      pathUnwrapping : 1,
      pathResolving : 'in',
      flattening : 0,
      singleUnwrapping : 0,
      mapValsUnwrapping : 0,
    });
    var expected =
    {
      'MultipleExports' : { 'proto' : pin( 'proto' ) }
    }
    test.identical( resolved, expected );
    test.close( 'mapValsUnwrapping : 0' );

    test.close( 'singleUnwrapping : 0' );

    test.close( 'flattening : 0' );

    test.close( 'pathResolving : in' );

    test.close( 'pathUnwrapping : 1' );

    test.close( 'proto' );

    debugger;
    return null;
  })

  /* - */

  module.ready.finallyKeep( ( err, arg ) =>
  {

    debugger;
    test.is( err === undefined );
    module.finit();

    if( err )
    throw err;
    return arg;
  });

  return module.ready.split();
}

pathsResolveOutFileOfExports.timeOut = 130000;

// --
// define class
// --

var Self =
{

  name : 'Tools/atop/WillInternals',
  silencing : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    tempDir : null,
    assetDirPath : null
  },

  tests :
  {

    buildSimple,
    makeNamed,
    makeAnon,
    makeOutNamed,
    clone,

    buildsResolve,
    pathsResolve,
    pathsResolveImportIn,
    pathsResolveOutFileOfExports,

  }

}

// --
// export
// --

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
