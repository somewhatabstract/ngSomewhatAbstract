###
## <reference path="../angular-sa.js"/>
###

describe 'somewhatabstract - angular-sa', ->
  Given -> module 'somewhatabstract'
  
  describe 'saHttpActivityInterceptor', ->
    Given -> module ($provide) ->
      fakeNavigationGuard = jasmine.createSpyObj 'saNavigationGuard', ['registerGuardian']
      $provide.value 'saNavigationGuard', fakeNavigationGuard;return
      
    describe 'exists', ->
      When => inject (saHttpActivityInterceptor) =>
        @saHttpActivityInterceptor = saHttpActivityInterceptor
      Then => expect(@saHttpActivityInterceptor).toBeDefined()
      
    describe '#guardian', ->
      describe 'is registered', ->
        Given => inject (saNavigationGuard) =>
          @saNavigationGuard = saNavigationGuard
        When => inject (saHttpActivityInterceptor) =>
        Then => expect(@saNavigationGuard.registerGuardian).toHaveBeenCalledWith jasmine.any(Function)
      
      describe 'returns undefined when there are no pending requests', ->
        Given => inject (saNavigationGuard) =>
          saNavigationGuard.registerGuardian.and.callFake (guardian) => @guardian = guardian
          inject (saHttpActivityInterceptor) =>
        When => @actual = @guardian()
        Then => expect(@actual).toBeUndefined()
    
      describe 'returns message when there are pending requests', ->
        Given => inject (saNavigationGuard) =>
          saNavigationGuard.registerGuardian.and.callFake (guardian) => @guardian = guardian
          inject (saHttpActivityInterceptor) => saHttpActivityInterceptor.request { method: "POST" }
        When => @actual = @guardian()
        Then => expect(@actual).toBeDefined()
  
  describe 'saNavigationGuard', ->
    describe 'exists', ->
      When => inject (saNavigationGuard) =>
        @saNavigationGuard = saNavigationGuard
      Then => expect(@saNavigationGuard).toBeDefined()
      
  describe 'saEditableField', ->
    Given -> module ($provide) ->
      fakeFieldController = jasmine.createSpyObj 'saFieldController', ['showField']
      $provide.value 'saFieldController', fakeFieldController;return
  
    describe 'exists', ->
      When => inject (saEditableFieldDirective) =>
        @saEditableField = saEditableFieldDirective
      Then => expect(@saEditableField).toBeDefined()
      
    describe 'compiles', ->
      Given => inject ($rootScope) =>
        @scope = $rootScope.$new()
        @scope.field = 'test'
        @htmlFixture = angular.element('<sa-editable-field sa-field-name="Test" ng-model="field"></sa-editable-field>');
      When => inject ($compile) =>
        $compile(@htmlFixture)(@scope)
        @scope.$apply()
      Then => @htmlFixture.find('label').length == 1
      And => @htmlFixture.find('label').text() == 'Test'
      And => @htmlFixture.find('input').length == 1
      And => @htmlFixture.find('button').length == 1
    
  describe 'saFieldController', ->
    Given -> module ($provide) ->
      $provide.value '$window', jasmine.createSpyObj('$window', ['alert']);return
      
    describe 'exists', ->
      Given => inject ($rootScope) =>
        @scope = $rootScope.$new()
      When => inject ($controller) =>
        @saFieldController = $controller 'saFieldController', { $scope: @scope }
      Then => expect(@saFieldController).toBeDefined()
      
    describe '#showField', ->
      describe 'exists', ->
        Given => inject ($rootScope) =>
          @scope = $rootScope.$new()
        When => inject ($controller) =>
          @saFieldController = $controller 'saFieldController', { $scope: @scope }
        Then => expect(@scope.showField).toEqual jasmine.any(Function)
        
      describe 'calls $window.alert', ->
        Given => inject ($rootScope, $controller, $window) =>
          @scope = $rootScope.$new()
          @windowService = $window
          @saFieldController = $controller 'saFieldController', { $scope: @scope }
        When => @scope.showField()
        Then => expect(@windowService.alert).toHaveBeenCalled()
      
      describe 'alert includes $scope.fieldName', ->
        Given => inject ($rootScope, $controller, $window) =>
          @scope = $rootScope.$new()
          @scope.fieldName = "Test Name"
          @windowService = $window
          @saFieldController = $controller 'saFieldController', { $scope: @scope }
        When => @scope.showField()
        Then => expect(@windowService.alert.calls.mostRecent().args[0]).toMatch /.*Test Name.*/
        
      describe 'alert includes $scope.fieldValue', ->
        Given => inject ($rootScope, $controller, $window) =>
          @scope = $rootScope.$new()
          @scope.fieldValue = "Test Value"
          @windowService = $window
          @saFieldController = $controller 'saFieldController', { $scope: @scope }
        When => @scope.showField()
        Then => expect(@windowService.alert.calls.mostRecent().args[0]).toMatch /.*Test Value.*/