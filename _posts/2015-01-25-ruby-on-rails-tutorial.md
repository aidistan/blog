---
layout: post
title: "Ruby on Rails Tutorial"
description: "带你走进 Rails 的国度"
modified: 2015-01-25 15:44:59 +0800
tags: [读书, 极客]
link: https://www.railstutorial.org/
---

Rails 确实是一个伟大的框架，然而“干货” (Do not Repeat Yourself, DRY) 和“惯例先于配置” (Conventions over Configurations, CoC) 的思想在解放生产力的同时，也极大地增加了本身的学习成本。我想不论是刚入门的初学者还是有所成的魔法师，对 Rails 都有相同的问题：“这个法术到底怎么学 / 我是怎么学会这个法术的？”

幸好有此书带领我们走过版本管理，跨过测试驱动，穿过应用部署，趟过 Ruby，来到 Rails 的国度。感谢 Michael Hartl, : )

# 摘抄

## Single or double quotes

> Finally, it’s worth noting that, in the common case that single and double quotes are essentially interchangeable, you’ll often find that the source code switches between the two without any apparent pattern. There’s really nothing to be done about this, except to say, “Welcome to Ruby!”

## When to test

> When deciding when and how to test, it’s helpful to understand why to test. In my view, writing automated tests has three main benefits:
>
> - Tests protect against regressions, where a functioning feature stops working for some reason.
> - Tests allow code to be refactored (i.e., changing its form without changing its function) with greater confidence.
> - Tests act as a client for the application code, thereby helping determine its design and its interface with other parts of the system.
>
> Although none of the above benefits require that tests be written first, there are many circumstances where test-driven development (TDD) is a valuable tool to have in your kit. Deciding when and how to test depends in part on how comfortable you are writing tests; many developers find that, as they get better at writing tests, they are more inclined to write them first. It also depends on how difficult the test is relative to the application code, how precisely the desired features are known, and how likely the feature is to break in the future.
>
> In this context, it’s helpful to have a set of guidelines on when we should test first (or test at all). Here are some suggestions based on my own experience:
>
> - When a test is especially short or simple compared to the application code it tests, lean toward writing the test first.
> - When the desired behavior isn’t yet crystal clear, lean toward writing the application code first, then write a test to codify the result.
> - Because security is a top priority, err on the side of writing tests of the security model first.
> - Whenever a bug is found, write a test to reproduce it and protect against regressions, then write the application code to fix it.
> - Lean against writing tests for code (such as detailed HTML structure) likely to change in the future.
> - Write tests before refactoring code, focusing on testing error-prone code that’s especially likely to break.
>
> In practice, the guidelines above mean that we’ll usually write controller and model tests first and integration tests (which test functionality across models, views, and controllers) second. And when we’re writing application code that isn’t particularly brittle or error-prone, or is likely to change (as is often the case with views), we’ll often skip testing altogether.
