+++
date = "2017-03-20T19:35:35+11:00"
title = "Get started with Rhize"
description = "From deploying the hub to building data-science queries, Rhize docs have the information you need."
[menu.main]
name = "Home"
identifier = "home"
weight = 0
+++

<div class="landing">
  <div class="hero">
    <h1>The Rhize Manufacturing Data Hub</h1>
    <p>
      The Rhize Manufacturing Data Hub has been designed from the ground up to transform industrial data management. It is scalable, distributed, highly available, and ready for every level of a manufacturing operation.
    </p>

  </div>
  <div class="item">
    <div class="icon"><i class="fa fa-info-circle" aria-hidden="true"></i></div>
    <a href="{{< relref "/get-started/introduction">}}">
      <h2>Introduction</h2>
      <p>
      A data hub for real manufacturing problems, based on open standards and open source.
      </p>
    </a>
  </div>

  <div class="item">
    <div class="icon"><i class="fa fa-building" aria-hidden="true"></i></div>
    <a href="{{< relref "/deploy">}}">
      <h2>Deploy</h2>
      <p>
      Install, backup, upgrade, and restore.
      </p>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="fa fa-wrench" aria-hidden="true"></i></div>
    <a href="{{< relref "/how-to">}}">
      <h2>User guides</h2>
      <p>
      Model processes, write event-driven workflows, query, and build custom frontends.
      </p>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="lni lni-keyword-research" aria-hidden="true"></i></div>
    <a href="{{< relref "/concepts/datahub">}}">
      <h2>Concepts</h2>
      <p>
      Explanations about why and how Rhize works.
      </p>
    </a>
  </div>
  <div class="item">
    {{< gql-icon >}}
    <a  href="{{< relref "/reference">}}">
      <h2>Reference</h2>
      <p>
      Look up syntax, definitions, parameters, and more
      </p>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="fa fa-level-up" aria-hidden="true"></i></div>
    <a href="{{< relref "/releases">}}">
      <h2>Releases</h2>
      <p>
        What's new in Rhize.
      </p>
    </a>
  </div>

</div>

<style>
  .content-wrapper {
    margin: 0 auto;
    max-width: 1200px;
    border: none;
  }
  article {
    max-width: none;
  }
  article h1 {
    border: none;
  }
  #sidebar {
    display: none;
  }
  article h1.post-title {
    display: none;
  }
</style>
