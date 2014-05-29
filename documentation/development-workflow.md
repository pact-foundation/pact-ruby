# Development Workflow

Using consumer driven contracts enables you to reverse the "normal" order of development, allowing you to build your consumer, in its entirety if need be, before you build your provider.

The development process will be different for every organisation, but this is one that has worked for the pact authors.

## Initial development
1. Write consumer tests with pact
1. Implement consumer 
1. Add pact:publish task to consumer build or publish pact as CI artifact
1. Create provider project
1. Configure pact:verify task to point to latest published pact
1. Implement provider until pact:verify passes

## New features

1. Add new feature, with pact specs, to consumer project on a branch.
1. In the provider project, use `rake pact:verify:at[/path/to/pact/on/branch]` to verify the new pact.
1. Commit/release new provider feature.
1. Merge consumer branch into master.

This may seem complex, but it is actually sufacing the underlying reality, that you cannot add new functionality to the consumer before it can be supported by the provider, but that the functionality that the provider supports should still be driven by the needs of the consumer.
