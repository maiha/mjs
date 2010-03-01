require File.join(File.dirname(__FILE__), '/spec_helper')

class HelperSandbox
  include Mjs::Helper
end

module Spec::Example::Subject::ExampleGroupMethods
  def remote_function(opts, expected = nil, &block)
    it "remote_function(#{opts.inspect})" do
      subject.remote_function(opts).should == (expected || block.call)
    end
  end
end

describe Mjs::Helper do
  subject {HelperSandbox.new}

  ######################################################################
  ### link_to

  provide :link_to

  describe "#link_to" do
    def call(opts = {})
      subject.link_to("label", '/', opts)
    end

    it "should not call remote_function" do
      mock(subject).remote_function.never
      call
    end

    describe " should call remote_function" do
      before do
        mock(subject).remote_function.with_any_args
      end

      it "when :remote given" do
        call :remote => true
      end

      it "when :submit given" do
        call :submit=>:form
      end

      it "when :update given" do
        call :remote=>:dst
      end
    end
  end

  ######################################################################
  ### button_to

  provide :button_to

  describe "#button_to" do
    def call(opts = {})
      subject.button_to("label", '/', opts)
    end

    it "should not call remote_function" do
      mock(subject).remote_function.never
      call
    end

    describe " should call remote_function" do
      before do
        mock(subject).remote_function.with_any_args
      end

      it "when :remote given" do
        call :remote => true
      end

      it "when :submit given" do
        call :submit=>:form
      end

      it "when :update given" do
        call :remote=>:dst
      end
    end
  end

  ######################################################################
  ### remote_function

  provide :remote_function

  remote_function(:url=>'/') do
    "jQuery.ajax({dataType:'script', url:'/'});"
  end

  remote_function(:url=>'/', :remote=>true) do
    "jQuery.ajax({dataType:'script', url:'/'});"
  end

  remote_function(:url=>'/', :submit=>:form) do
    "jQuery.ajax({data:jQuery('#form input, #form select, #form textarea').serialize(), dataType:'script', type:'POST', url:'/'});"
  end

  remote_function(:url=>'/', :submit=>"form") do
    "jQuery.ajax({data:jQuery('form').serialize(), dataType:'script', type:'POST', url:'/'});"
  end

  remote_function(:url=>'/', :update=>:dst) do
    "jQuery.ajax({dataType:'html', success:function(request){jQuery('#dst').html(request)}, type:'POST', url:'/'});"
  end

  remote_function(:url=>'/', :update=>"dst") do
    "jQuery.ajax({dataType:'html', success:function(request){jQuery('dst').html(request)}, type:'POST', url:'/'});"
  end

  remote_function(:url=>'/', :update=>:dst, :type=>:get) do
    "jQuery.ajax({dataType:'html', success:function(request){jQuery('#dst').html(request)}, type:'GET', url:'/'});"
  end

  remote_function(:url=>'/', :update=>"dst", :type=>:get) do
    "jQuery.ajax({dataType:'html', success:function(request){jQuery('dst').html(request)}, type:'GET', url:'/'});"
  end

end
