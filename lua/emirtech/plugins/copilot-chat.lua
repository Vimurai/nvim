return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "github/copilot.vim" }, -- or: "zbirenbaum/copilot.lua"
		{ "nvim-lua/plenary.nvim", branch = "master" },
		{ "folke/which-key.nvim" },
	},
	lazy = false,
	build = "make tiktoken",

	opts = function()
		return {
			prompts = {
				-- Originals
				Rename = {
					prompt = "Please rename the variable or function to something more descriptive and meaningful based on the provided code context.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				MakeComponent = {
					prompt = "Please create a new component based on the provided code context.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- Explain / Review
				ExplainLikeSenior = {
					prompt = "Explain the code at a senior level: goals, data flow, invariants, trade-offs, risks.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ExplainLikeJunior = {
					prompt = "Explain the code for a beginner: what it does, step-by-step, with a tiny example.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ReviewBugs = {
					prompt = "Find likely bugs, edge cases, logic errors; suggest minimal fixes.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				SecurityReview = {
					prompt = "Security review: inputs/outputs, trust boundaries, injection, authn/authz, secrets, logging. Propose fixes.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				PerformanceReview = {
					prompt = "Analyze time/space complexity and suggest concrete optimizations with trade-offs.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ConcurrencyReview = {
					prompt = "Check for concurrency issues: shared state, races, deadlocks, async pitfalls. Suggest safer patterns.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- Refactor / Clean Architecture
				RefactorForReadability = {
					prompt = "Refactor for clarity & maintainability. Keep behavior identical. Prefer small pure functions, good names, remove duplication.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				RefactorToCleanArchitecture = {
					prompt = "Refactor to a lightweight Clean Architecture (domain/entities+VOs, application/use-cases, infrastructure/adapters). Outline files & responsibilities.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				ExtractFunction = {
					prompt = "Extract small, well-named functions. Keep side-effects at the edges; return pure values where possible.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ExtractInterface = {
					prompt = "Extract an interface to improve testability. Show interface and updated usage points.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddGuardClauses = {
					prompt = "Add guard clauses and fail-fast checks. Keep messages actionable and avoid deep nesting.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddErrorHandling = {
					prompt = "Add robust error handling (clear exceptions or Result types). Avoid swallowing errors.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddLogging = {
					prompt = "Add structured logging (operation names, correlation IDs, key fields). Keep it low-noise.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddTelemetry = {
					prompt = "Instrument with metrics/traces (latency, counts, error rates). Suggest metric names and labels.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- DDD / .NET
				DDDIdentifyAggregates = {
					prompt = "Identify aggregates, aggregate roots, bounded contexts; propose entity/VO splits and domain events.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				CreateDomainEvent = {
					prompt = "Propose a Domain Event (payload + naming). Show IDomainEvent interface and a sample handler wiring.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				AddNullabilityAnnotations = {
					prompt = "Add C# nullable annotations & checks; eliminate possible NREs and show safer signatures.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ConvertToLINQ = {
					prompt = "Convert to idiomatic LINQ where it improves clarity/performance. Keep it readable.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				OptimizeLINQ = {
					prompt = "Optimize LINQ (defer execution, avoid multiple enumeration, push filters to DB).",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				WriteXmlDocComments = {
					prompt = "Write concise C# XML doc comments (summary, params, returns, exceptions).",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				GenerateFluentValidation = {
					prompt = "Propose FluentValidation rules for DTOs/entities (include edge cases and custom validators).",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				GenerateMediatRHandler = {
					prompt = "Sketch a MediatR request/response and handler with validation, domain call, and result mapping.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				IntroduceEnum = {
					prompt = "Replace magic constants with a typed Enum (or smart enum). Show C# declaration and integration.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				IntroduceValueObject = {
					prompt = "Identify a Value Object (invariants, validation, equality). Show a C# example and Domain placement.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- Testing
				AddUnitTests = {
					prompt = "Generate focused unit tests (Arrange/Act/Assert): success, failure, and edge cases. Use NUnit/xUnit style.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddPropertyTests = {
					prompt = "Propose property-based tests: identify invariants and boundaries to fuzz.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddIntegrationTest = {
					prompt = "Outline an integration test: setup, external deps, fixtures, teardown.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				AddTestDataBuilders = {
					prompt = "Create Test Data Builders for complex objects. Show fluent builder API and examples.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- API / DTO / Mapping
				CreateDTOs = {
					prompt = "Define DTOs vs domain objects; show mapping code (Mapster/AutoMapper) and where to place it.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ValidateAPIContracts = {
					prompt = "Review API contract clarity and versioning; suggest breaking and non-breaking changes with examples.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- Data / SQL
				SQLReview = {
					prompt = "Review SQL for correctness and performance; add indexes, parameterization, and safer patterns.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				OptimizeQuery = {
					prompt = "Optimize query logic: reduce roundtrips, batch operations, pagination, projection.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- JS/TS/Vue helpers
				ConvertToAsyncAwait = {
					prompt = "Convert callbacks/promises to idiomatic async/await with proper error handling.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				ExplainReactivity = {
					prompt = "Explain Vue reactivity implications; refs/reactive/computed pitfalls and fixes.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				-- QoL
				ReviewNaming = {
					prompt = "Review names and propose clearer, domain-oriented names aligned with ubiquitous language.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				GenerateCommitConventional = {
					prompt = "Write a Conventional Commit subject and body (include scope and brief rationale).",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				CreateChangelogEntry = {
					prompt = "Draft a concise CHANGELOG entry (Added/Changed/Fixed/Removed).",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				CreateGitHubIssue = {
					prompt = "Create a GitHub issue from the code: title, problem statement, acceptance criteria, risks.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
				TranslateCommentsToEnglish = {
					prompt = "Translate comments/identifiers to clear English while keeping code intact.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},

				TranslateCommentsToGerman = {
					prompt = "Translate comments/identifiers to clear German while keeping code intact.",
					selection = function(source)
						return require("CopilotChat.select").visual(source)
							or require("CopilotChat.select").buffer(source)
					end,
				},
			},
		}
	end,

	config = function(_, opts)
		require("CopilotChat").setup(opts)

		local wk = require("which-key")

		---------------------------------------------------------------------------
		-- NORMAL MODE MAPPINGS (separate block)
		---------------------------------------------------------------------------
		wk.add({
			{ "<leader>z", group = "CopilotChat (Normal)", mode = "n" },

			-- Open CopilotChat
			{
				"<leader>zC",
				"<cmd>CopilotChat<CR>",
				desc = "Open CopilotChat",
				mode = "n",
			},

			-- Explain
			{ "<leader>ze", group = "Explain", mode = "n" },
			{
				"<leader>zes",
				"<cmd>CopilotChatExplainLikeSenior<CR>",
				desc = "Explain: Senior",
				mode = "n",
			},
			{
				"<leader>zej",
				"<cmd>CopilotChatExplainLikeJunior<CR>",
				desc = "Explain: Junior",
				mode = "n",
			},

			-- Review
			{ "<leader>zr", group = "Review", mode = "n" },
			{
				"<leader>zrb",
				"<cmd>CopilotChatReviewBugs<CR>",
				desc = "Bugs & Edge Cases",
				mode = "n",
			},
			{
				"<leader>zrs",
				"<cmd>CopilotChatSecurityReview<CR>",
				desc = "Security Review",
				mode = "n",
			},
			{
				"<leader>zrp",
				"<cmd>CopilotChatPerformanceReview<CR>",
				desc = "Performance Review",
				mode = "n",
			},
			{
				"<leader>zrc",
				"<cmd>CopilotChatConcurrencyReview<CR>",
				desc = "Concurrency Review",
				mode = "n",
			},
			{
				"<leader>zRN",
				"<cmd>CopilotChatReviewNaming<CR>",
				desc = "Review Naming",
				mode = "n",
			},

			-- Refactor
			{ "<leader>zf", group = "Refactor", mode = "n" },
			{
				"<leader>zfr",
				"<cmd>CopilotChatRefactorForReadability<CR>",
				desc = "Refactor: Readability",
				mode = "n",
			},
			{
				"<leader>zfa",
				"<cmd>CopilotChatRefactorToCleanArchitecture<CR>",
				desc = "Refactor: Clean Architecture",
				mode = "n",
			},
			{
				"<leader>zfx",
				"<cmd>CopilotChatExtractFunction<CR>",
				desc = "Extract Function",
				mode = "n",
			},
			{
				"<leader>zfi",
				"<cmd>CopilotChatExtractInterface<CR>",
				desc = "Extract Interface",
				mode = "n",
			},
			{
				"<leader>zfg",
				"<cmd>CopilotChatAddGuardClauses<CR>",
				desc = "Add Guard Clauses",
				mode = "n",
			},
			{
				"<leader>zfe",
				"<cmd>CopilotChatAddErrorHandling<CR>",
				desc = "Add Error Handling",
				mode = "n",
			},
			{
				"<leader>zfl",
				"<cmd>CopilotChatAddLogging<CR>",
				desc = "Add Logging",
				mode = "n",
			},
			{
				"<leader>zft",
				"<cmd>CopilotChatAddTelemetry<CR>",
				desc = "Add Telemetry",
				mode = "n",
			},

			-- DDD / .NET
			{ "<leader>zd", group = "DDD/.NET", mode = "n" },
			{
				"<leader>zdA",
				"<cmd>CopilotChatDDDIdentifyAggregates<CR>",
				desc = "Identify Aggregates",
				mode = "n",
			},
			{
				"<leader>zdE",
				"<cmd>CopilotChatCreateDomainEvent<CR>",
				desc = "Create Domain Event",
				mode = "n",
			},
			{
				"<leader>zdN",
				"<cmd>CopilotChatAddNullabilityAnnotations<CR>",
				desc = "Add Nullability",
				mode = "n",
			},
			{
				"<leader>zdO",
				"<cmd>CopilotChatOptimizeLINQ<CR>",
				desc = "Optimize LINQ",
				mode = "n",
			},
			{
				"<leader>zdm",
				"<cmd>CopilotChatGenerateMediatRHandler<CR>",
				desc = "MediatR Handler",
				mode = "n",
			},
			{
				"<leader>zdn",
				"<cmd>CopilotChatIntroduceEnum<CR>",
				desc = "Introduce Enum",
				mode = "n",
			},
			{
				"<leader>zdo",
				"<cmd>CopilotChatConvertToLINQ<CR>",
				desc = "Convert to LINQ",
				mode = "n",
			},
			{
				"<leader>zdv",
				"<cmd>CopilotChatIntroduceValueObject<CR>",
				desc = "Introduce Value Object",
				mode = "n",
			},
			{
				"<leader>zdW",
				"<cmd>CopilotChatWriteXmlDocComments<CR>",
				desc = "XML Doc Comments",
				mode = "n",
			},
			{
				"<leader>zdF",
				"<cmd>CopilotChatGenerateFluentValidation<CR>",
				desc = "FluentValidation",
				mode = "n",
			},

			-- Tests
			{ "<leader>zt", group = "Tests", mode = "n" },
			{
				"<leader>ztu",
				"<cmd>CopilotChatAddUnitTests<CR>",
				desc = "Unit Tests",
				mode = "n",
			},
			{
				"<leader>ztp",
				"<cmd>CopilotChatAddPropertyTests<CR>",
				desc = "Property Tests",
				mode = "n",
			},
			{
				"<leader>zti",
				"<cmd>CopilotChatAddIntegrationTest<CR>",
				desc = "Integration Test",
				mode = "n",
			},
			{
				"<leader>ztb",
				"<cmd>CopilotChatAddTestDataBuilders<CR>",
				desc = "Test Data Builders",
				mode = "n",
			},

			-- API / DTO
			{ "<leader>za", group = "API/DTO", mode = "n" },
			{
				"<leader>zad",
				"<cmd>CopilotChatCreateDTOs<CR>",
				desc = "Create DTOs",
				mode = "n",
			},
			{
				"<leader>zav",
				"<cmd>CopilotChatValidateAPIContracts<CR>",
				desc = "Validate Contracts",
				mode = "n",
			},

			-- Query / SQL
			{ "<leader>zq", group = "Query/SQL", mode = "n" },
			{
				"<leader>zqr",
				"<cmd>CopilotChatSQLReview<CR>",
				desc = "SQL Review",
				mode = "n",
			},
			{
				"<leader>zqo",
				"<cmd>CopilotChatOptimizeQuery<CR>",
				desc = "Optimize Query",
				mode = "n",
			},

			-- JS/TS & Vue
			{ "<leader>zj", group = "JS/TS", mode = "n" },
			{
				"<leader>zja",
				"<cmd>CopilotChatConvertToAsyncAwait<CR>",
				desc = "Convert to async/await",
				mode = "n",
			},
			{ "<leader>zv", group = "Vue", mode = "n" },
			{
				"<leader>zvr",
				"<cmd>CopilotChatExplainReactivity<CR>",
				desc = "Explain Reactivity",
				mode = "n",
			},

			-- Misc
			{ "<leader>zm", group = "Misc", mode = "n" },
			{
				"<leader>zmC",
				"<cmd>CopilotChatMakeComponent<CR>",
				desc = "Make Component",
				mode = "n",
			},
			{
				"<leader>zmG",
				"<cmd>CopilotChatGenerateCommitConventional<CR>",
				desc = "Conventional Commit",
				mode = "n",
			},
			{
				"<leader>zmL",
				"<cmd>CopilotChatCreateChangelogEntry<CR>",
				desc = "Changelog Entry",
				mode = "n",
			},
			{
				"<leader>zmI",
				"<cmd>CopilotChatCreateGitHubIssue<CR>",
				desc = "GitHub Issue",
				mode = "n",
			},
		})

		---------------------------------------------------------------------------
		-- VISUAL MODE MAPPINGS (separate block)
		---------------------------------------------------------------------------
		wk.add({
			{ "<leader>z", group = "CopilotChat (Visual)", mode = "v" },

			-- Explain
			{ "<leader>ze", group = "Explain", mode = "v" },
			{
				"<leader>zes",
				"<cmd>CopilotChatExplainLikeSenior<CR>",
				desc = "Explain: Senior",
				mode = "v",
			},
			{
				"<leader>zej",
				"<cmd>CopilotChatExplainLikeJunior<CR>",
				desc = "Explain: Junior",
				mode = "v",
			},

			-- Review
			{ "<leader>zr", group = "Review", mode = "v" },
			{
				"<leader>zrb",
				"<cmd>CopilotChatReviewBugs<CR>",
				desc = "Bugs & Edge Cases",
				mode = "v",
			},
			{
				"<leader>zrs",
				"<cmd>CopilotChatSecurityReview<CR>",
				desc = "Security Review",
				mode = "v",
			},
			{
				"<leader>zrp",
				"<cmd>CopilotChatPerformanceReview<CR>",
				desc = "Performance Review",
				mode = "v",
			},
			{
				"<leader>zrc",
				"<cmd>CopilotChatConcurrencyReview<CR>",
				desc = "Concurrency Review",
				mode = "v",
			},

			-- Refactor
			{ "<leader>zf", group = "Refactor", mode = "v" },
			{
				"<leader>zfr",
				"<cmd>CopilotChatRefactorForReadability<CR>",
				desc = "Refactor: Readability",
				mode = "v",
			},
			{
				"<leader>zfa",
				"<cmd>CopilotChatRefactorToCleanArchitecture<CR>",
				desc = "Refactor: Clean Architecture",
				mode = "v",
			},
			{
				"<leader>zfx",
				"<cmd>CopilotChatExtractFunction<CR>",
				desc = "Extract Function",
				mode = "v",
			},
			{
				"<leader>zfi",
				"<cmd>CopilotChatExtractInterface<CR>",
				desc = "Extract Interface",
				mode = "v",
			},
			{
				"<leader>zfg",
				"cmd>CopilotChatAddGuardClauses<CR>",
				desc = "Add Guard Clauses",
				mode = "v",
			},
			{
				"<leader>zfe",
				"<cmd>CopilotChatAddErrorHandling<CR>",
				desc = "Add Error Handling",
				mode = "v",
			},
			{
				"<leader>zfl",
				"<cmd>CopilotChatAddLogging<CR>",
				desc = "Add Logging",
				mode = "v",
			},
			{
				"<leader>zft",
				"<cmd>CopilotChatAddTelemetry<CR>",
				desc = "Add Telemetry",
				mode = "v",
			},

			-- DDD / .NET
			{ "<leader>zd", group = "DDD/.NET", mode = "v" },
			{
				"<leader>zdA",
				"<cmd>CopilotChatDDDIdentifyAggregates<CR>",
				desc = "Identify Aggregates",
				mode = "v",
			},
			{
				"<leader>zdE",
				"<cmd>CopilotChatCreateDomainEvent<CR>",
				desc = "Create Domain Event",
				mode = "v",
			},
			{
				"<leader>zdN",
				"<cmd>CopilotChatAddNullabilityAnnotations<CR>",
				desc = "Add Nullability",
				mode = "v",
			},
			{
				"<leader>zdO",
				"<cmd>CopilotChatOptimizeLINQ<CR>",
				desc = "Optimize LINQ",
				mode = "v",
			},
			{
				"<leader>zdm",
				"<cmd>CopilotChatGenerateMediatRHandler<CR>",
				desc = "MediatR Handler",
				mode = "v",
			},
			{
				"<leader>zdn",
				"<cmd>CopilotChatIntroduceEnum<CR>",
				desc = "Introduce Enum",
				mode = "v",
			},
			{
				"<leader>zdo",
				"<cmd>CopilotChatConvertToLINQ<CR>",
				desc = "Convert to LINQ",
				mode = "v",
			},
			{
				"<leader>zdv",
				"<cmd>CopilotChatIntroduceValueObject<CR>",
				desc = "Introduce Value Object",
				mode = "v",
			},
			{
				"<leader>zdW",
				"<cmd>CopilotChatWriteXmlDocComments<CR>",
				desc = "XML Doc Comments",
				mode = "v",
			},
			{
				"<leader>zdF",
				"<cmd>CopilotChatGenerateFluentValidation<CR>",
				desc = "FluentValidation",
				mode = "v",
			},

			-- Tests
			{ "<leader>zt", group = "Tests", mode = "v" },
			{
				"<leader>ztu",
				"<cmd>CopilotChatAddUnitTests<CR>",
				desc = "Unit Tests",
				mode = "v",
			},
			{
				"<leader>ztp",
				"<cmd>CopilotChatAddPropertyTests<CR>",
				desc = "Property Tests",
				mode = "v",
			},
			{
				"<leader>zti",
				"<cmd>CopilotChatAddIntegrationTest<CR>",
				desc = "Integration Test",
				mode = "v",
			},
			{
				"<leader>ztb",
				"<cmd>CopilotChatAddTestDataBuilders<CR>",
				desc = "Test Data Builders",
				mode = "v",
			},

			-- API / DTO
			{ "<leader>za", group = "API/DTO", mode = "v" },
			{
				"<leader>zad",
				"<cmd>CopilotChatCreateDTOs<CR>",
				desc = "Create DTOs",
				mode = "v",
			},
			{
				"<leader>zav",
				"<cmd>CopilotChatValidateAPIContracts<CR>",
				desc = "Validate Contracts",
				mode = "v",
			},

			-- Query / SQL
			{ "<leader>zq", group = "Query/SQL", mode = "v" },
			{
				"<leader>zqr",
				"<cmd>CopilotChatSQLReview<CR>",
				desc = "SQL Review",
				mode = "v",
			},
			{
				"<leader>zqo",
				"<cmd>CopilotChatOptimizeQuery<CR>",
				desc = "Optimize Query",
				mode = "v",
			},

			-- JS/TS & Vue
			{ "<leader>zj", group = "JS/TS", mode = "v" },
			{
				"<leader>zja",
				"<cmd>CopilotChatConvertToAsyncAwait<CR>",
				desc = "Convert to async/await",
				mode = "v",
			},
			{ "<leader>zv", group = "Vue", mode = "v" },
			{
				"<leader>zvr",
				"<cmd>CopilotChatExplainReactivity<CR>",
				desc = "Explain Reactivity",
				mode = "v",
			},

			-- Misc
			{ "<leader>zm", group = "Misc", mode = "v" },
			{
				"<leader>zmR",
				"<cmd>CopilotChatRename<CR>",
				desc = "Rename (Selection)",
				mode = "v",
			},
			{
				"<leader>zmC",
				"<cmd>CopilotChatMakeComponent<CR>",
				desc = "Make Component",
				mode = "v",
			},
			{
				"<leader>zme",
				"<cmd>CopilotChatGenerateCommitConventional<CR>",
				desc = "Translate → EN",
				mode = "v",
			},
			{
				"<leader>zmg",
				"<cmd>CopilotChatCreateChangelogEntry<CR>",
				desc = "Translate → DE",
				mode = "v",
			},
		})
	end,
}
