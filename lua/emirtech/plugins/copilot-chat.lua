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
		local select = require("CopilotChat.select")
		local vis_or_buf = function(src)
			return select.visual(src) or select.buffer(src)
		end

		return {
			prompts = {
				---------------------------------------------------------------------------
				-- Language-agnostic (works for both C# and JS/TS)
				---------------------------------------------------------------------------
				Rename = {
					prompt = "Rename to a clearer, domain-meaningful name based on context.",
					selection = vis_or_buf,
				},
				MakeComponent = {
					prompt = "Create a new component based on the selected code and its responsibilities.",
					selection = vis_or_buf,
				},
				ExplainLikeSenior = {
					prompt = "Explain senior-level: goals, data flow, invariants, trade-offs, risks.",
					selection = vis_or_buf,
				},
				ExplainLikeJunior = {
					prompt = "Explain for a beginner: what it does, step-by-step with a tiny example.",
					selection = vis_or_buf,
				},
				ReviewBugs = {
					prompt = "Find likely bugs, edge cases, logic errors; suggest minimal fixes.",
					selection = vis_or_buf,
				},
				SecurityReview = {
					prompt = "Security review: inputs/outputs, injection, authn/authz, secrets, logging. Propose fixes.",
					selection = vis_or_buf,
				},
				PerformanceReview = {
					prompt = "Analyze time/space complexity and suggest concrete optimizations with trade-offs.",
					selection = vis_or_buf,
				},
				ConcurrencyReview = {
					prompt = "Check for concurrency issues: shared state, races, async pitfalls. Suggest safer patterns.",
					selection = vis_or_buf,
				},

				RefactorForReadability = {
					prompt = "Refactor for clarity & maintainability without changing behavior. Prefer small pure functions, great names, remove duplication.",
					selection = vis_or_buf,
				},
				ExtractFunction = {
					prompt = "Extract small, well-named pure functions. Keep side-effects at the edges.",
					selection = vis_or_buf,
				},
				ExtractInterface = {
					prompt = "Extract an interface/contract to improve testability. Show interface plus updated usage points.",
					selection = vis_or_buf,
				},
				AddGuardClauses = {
					prompt = "Add guard clauses and fail-fast checks; avoid deep nesting. Clear messages.",
					selection = vis_or_buf,
				},
				AddErrorHandling = {
					prompt = "Add robust error handling; avoid swallowing errors. Prefer explicit errors/Results.",
					selection = vis_or_buf,
				},
				AddLogging = {
					prompt = "Add structured logging (operation names, correlation IDs, key fields) with low noise.",
					selection = vis_or_buf,
				},
				AddTelemetry = {
					prompt = "Instrument with metrics/traces (latency, counts, error rates). Propose metric names and labels.",
					selection = vis_or_buf,
				},

				AddUnitTests = {
					prompt = "Generate focused unit tests (Arrange/Act/Assert): success, failure, edge cases.",
					selection = vis_or_buf,
				},
				AddPropertyTests = {
					prompt = "Propose property-based tests: invariants and boundaries to fuzz.",
					selection = vis_or_buf,
				},
				AddIntegrationTest = {
					prompt = "Outline an integration test: setup, external deps, fixtures, teardown.",
					selection = vis_or_buf,
				},
				AddTestDataBuilders = {
					prompt = "Create Test Data Builders for complex objects. Show fluent builder API and examples.",
					selection = vis_or_buf,
				},

				CreateDTOs = {
					prompt = "Define DTOs vs domain objects; show mapping code and where to place it.",
					selection = vis_or_buf,
				},
				ValidateAPIContracts = {
					prompt = "Review API contracts: clarity, versioning; list breaking/non-breaking changes with examples.",
					selection = vis_or_buf,
				},

				SQLReview = {
					prompt = "Review SQL for correctness/performance; indexes, parameterization, safer patterns.",
					selection = vis_or_buf,
				},
				OptimizeQuery = {
					prompt = "Optimize query logic: reduce roundtrips, batch operations, pagination, projection.",
					selection = vis_or_buf,
				},

				ReviewNaming = {
					prompt = "Review names; propose clearer, domain-oriented names aligned with ubiquitous language.",
					selection = vis_or_buf,
				},
				GenerateCommitConventional = {
					prompt = "Write a Conventional Commit (subject + body, include scope and brief rationale).",
					selection = vis_or_buf,
				},
				CreateChangelogEntry = {
					prompt = "Draft a concise CHANGELOG entry (Added/Changed/FIxed/Removed).",
					selection = vis_or_buf,
				},
				CreateGitHubIssue = {
					prompt = "Create a GitHub issue: title, problem statement, acceptance criteria, risks.",
					selection = vis_or_buf,
				},
				TranslateCommentsToEnglish = {
					prompt = "Translate comments/identifiers to clear English while keeping code intact.",
					selection = vis_or_buf,
				},
				TranslateCommentsToGerman = {
					prompt = "Translate comments/identifiers to clear German while keeping code intact.",
					selection = vis_or_buf,
				},

				---------------------------------------------------------------------------
				-- C# / .NET specific
				---------------------------------------------------------------------------
				DDDIdentifyAggregates = {
					prompt = "Identify aggregates, aggregate roots, bounded contexts; propose entity/VO splits and domain events.",
					selection = vis_or_buf,
				},
				CreateDomainEvent = {
					prompt = "Propose a Domain Event (payload + naming). Show IDomainEvent interface and a sample handler wiring.",
					selection = vis_or_buf,
				},
				AddNullabilityAnnotations = {
					prompt = "Add C# nullable annotations & checks; eliminate possible NREs; show safer signatures.",
					selection = vis_or_buf,
				},
				ConvertToLINQ = {
					prompt = "Convert to idiomatic LINQ where it improves clarity/performance without hurting readability.",
					selection = vis_or_buf,
				},
				OptimizeLINQ = {
					prompt = "Optimize LINQ (defer execution, avoid multiple enumeration, push filters to DB).",
					selection = vis_or_buf,
				},
				WriteXmlDocComments = {
					prompt = "Write concise C# XML doc comments (summary, params, returns, exceptions).",
					selection = vis_or_buf,
				},
				GenerateFluentValidation = {
					prompt = "Propose FluentValidation rules for DTOs/entities, including edge cases and custom validators.",
					selection = vis_or_buf,
				},
				GenerateMediatRHandler = {
					prompt = "Sketch a MediatR request/response and handler with validation, domain call, and result mapping.",
					selection = vis_or_buf,
				},
				IntroduceEnum = {
					prompt = "Replace magic constants with a typed Enum (or smart enum). Show C# declaration and integration.",
					selection = vis_or_buf,
				},
				IntroduceValueObject = {
					prompt = "Identify a Value Object (invariants, validation, equality). Show a C# example and Domain placement.",
					selection = vis_or_buf,
				},

				---------------------------------------------------------------------------
				-- JavaScript / TypeScript / Vue specific
				---------------------------------------------------------------------------
				JSConvertToAsyncAwait = {
					prompt = "Convert callbacks/promises to idiomatic async/await with proper try/catch and error propagation.",
					selection = vis_or_buf,
				},
				JSAddTypesTS = {
					prompt = "Add TypeScript types: interfaces/types for params/returns; narrow unknown/any; no over-broad types.",
					selection = vis_or_buf,
				},
				JSAddJSDoc = {
					prompt = "Add JSDoc (or TSDoc) comments with @param/@returns, examples, and error behavior.",
					selection = vis_or_buf,
				},
				JSGenerateZodSchema = {
					prompt = "Generate Zod schemas for the data shapes used; show parse/safeParse usage and error handling.",
					selection = vis_or_buf,
				},
				JSConvertCJS2ESM = {
					prompt = "Refactor CommonJS to modern ESM with correct default/named imports; update exports.",
					selection = vis_or_buf,
				},
				JSTreeShakeOptimize = {
					prompt = "Optimize for tree-shaking: split modules, avoid side effects, prefer named imports, remove dead code.",
					selection = vis_or_buf,
				},
				JSAddVitestTests = {
					prompt = "Create Vitest unit tests with setup/teardown and edge cases. Mock I/O and timers properly.",
					selection = vis_or_buf,
				},
				JSAddPlaywrightTest = {
					prompt = "Outline a Playwright e2e test: fixtures, selectors, waits, assertions, and auth handling.",
					selection = vis_or_buf,
				},
				JSSecurityReview = {
					prompt = "JS security review: XSS, SSRF, CSRF, prototype pollution, unsafe eval/new Function; propose fixes.",
					selection = vis_or_buf,
				},

				VueExplainReactivity = {
					prompt = "Explain Vue reactivity pitfalls; refs/reactive/computed/watch correctness and fixes.",
					selection = vis_or_buf,
				},

				VueExtractComponent = {
					prompt = "Extract an SFC component from selection; props/emits/slots; no global state leaks.",
					selection = vis_or_buf,
				},

				VueRefactorToComposable = {
					prompt = "Refactor logic into a Vue composable (useX). Define inputs/outputs, state, and cleanup.",
					selection = vis_or_buf,
				},

				VueCreatePiniaStore = {
					prompt = "Create a Pinia store with state/getters/actions; type-safe usage patterns.",
					selection = vis_or_buf,
				},
			},
		}
	end,

	config = function(_, opts)
		require("CopilotChat").setup(opts)
		local wk = require("which-key")

		---------------------------------------------------------------------------
		-- NORMAL MODE GROUPS
		---------------------------------------------------------------------------
		-- TOP-LEVEL GROUPS
		wk.add({
			{ "<leader>z", group = "CopilotChat", mode = "n" },
			{ "<leader>zC", group = "Common", mode = "n" }, -- NEW: Common
			{ "<leader>zc", group = "C#/.NET", mode = "n" },
			{ "<leader>zj", group = "JS/TS/Vue", mode = "n" },

			-- Open
			{ "<leader>zO", "<cmd>CopilotChat<CR>", desc = "Open CopilotChat", mode = "n" },
		})

		-- ====================== COMMON (language-agnostic) =========================
		wk.add({
			{ "<leader>zCe", group = "Explain/Review", mode = "n" },
			{ "<leader>zCf", group = "Refactor", mode = "n" },
			{ "<leader>zCt", group = "Tests", mode = "n" },
			{ "<leader>zCa", group = "API/DTO", mode = "n" },
			{ "<leader>zCq", group = "Query/SQL", mode = "n" },
			{ "<leader>zCm", group = "Misc", mode = "n" },

			-- Explain/Review
			{ "<leader>zCes", "<cmd>CopilotChatExplainLikeSenior<CR>", desc = "Explain: Senior", mode = "n" },
			{ "<leader>zCej", "<cmd>CopilotChatExplainLikeJunior<CR>", desc = "Explain: Junior", mode = "n" },
			{ "<leader>zCrb", "<cmd>CopilotChatReviewBugs<CR>", desc = "Review: Bugs", mode = "n" },
			{ "<leader>zCrs", "<cmd>CopilotChatSecurityReview<CR>", desc = "Security Review", mode = "n" },
			{ "<leader>zCrp", "<cmd>CopilotChatPerformanceReview<CR>", desc = "Performance Review", mode = "n" },
			{ "<leader>zCrc", "<cmd>CopilotChatConcurrencyReview<CR>", desc = "Concurrency Review", mode = "n" },

			-- Refactor
			{
				"<leader>zCfr",
				"<cmd>CopilotChatRefactorForReadability<CR>",
				desc = "Refactor: Readability",
				mode = "n",
			},
			{
				"<leader>zCfx",
				"<cmd>CopilotChatExtractFunction<CR>",
				desc = "Extract Function",
				mode = "n",
			},
			{
				"<leader>zCfi",
				"<cmd>CopilotChatExtractInterface<CR>",
				desc = "Extract Interface",
				mode = "n",
			},
			{
				"<leader>zCfg",
				"<cmd>CopilotChatAddGuardClauses<CR>",
				desc = "Add Guard Clauses",
				mode = "n",
			},
			{
				"<leader>zCfe",
				"<cmd>CopilotChatAddErrorHandling<CR>",
				desc = "Add Error Handling",
				mode = "n",
			},
			{
				"<leader>zCfl",
				"<cmd>CopilotChatAddLogging<CR>",
				desc = "Add Logging",
				mode = "n",
			},
			{
				"<leader>zCft",
				"<cmd>CopilotChatAddTelemetry<CR>",
				desc = "Add Telemetry",
				mode = "n",
			},

			-- Tests
			{ "<leader>zCtu", "<cmd>CopilotChatAddUnitTests<CR>", desc = "Tests: Unit", mode = "n" },
			{ "<leader>zCtp", "<cmd>CopilotChatAddPropertyTests<CR>", desc = "Tests: Property", mode = "n" },
			{ "<leader>zCti", "<cmd>CopilotChatAddIntegrationTest<CR>", desc = "Tests: Integration", mode = "n" },
			{ "<leader>zCtb", "<cmd>CopilotChatAddTestDataBuilders<CR>", desc = "Tests: Builders", mode = "n" },

			-- API/DTO
			{ "<leader>zCad", "<cmd>CopilotChatCreateDTOs<CR>", desc = "API: Create DTOs", mode = "n" },
			{
				"<leader>zCav",
				"<cmd>CopilotChatValidateAPIContracts<CR>",
				desc = "API: Validate Contracts",
				mode = "n",
			},

			-- Query/SQL
			{ "<leader>zCqr", "<cmd>CopilotChatSQLReview<CR>", desc = "SQL Review", mode = "n" },
			{ "<leader>zCqo", "<cmd>CopilotChatOptimizeQuery<CR>", desc = "Optimize Query", mode = "n" },

			-- Misc
			{
				"<leader>zCmr",
				"<cmd>CopilotChatRename<CR>",
				desc = "Rename",
				mode = "n",
			},
			{
				"<leader>zCmC",
				"<cmd>CopilotChatMakeComponent<CR>",
				desc = "Make Component",
				mode = "n",
			},
			{
				"<leader>zCmG",
				"<cmd>CopilotChatGenerateCommitConventional<CR>",
				desc = "Conventional Commit",
				mode = "n",
			},
			{
				"<leader>zCmL",
				"<cmd>CopilotChatCreateChangelogEntry<CR>",
				desc = "Changelog Entry",
				mode = "n",
			},
			{
				"<leader>zCmI",
				"<cmd>CopilotChatCreateGitHubIssue<CR>",
				desc = "GitHub Issue",
				mode = "n",
			},
		})

		-- =========================== C# /.NET ONLY ================================
		wk.add({
			{ "<leader>zcd", group = "DDD/.NET", mode = "n" },
			{
				"<leader>zcdA",
				"<cmd>CopilotChatDDDIdentifyAggregates<CR>",
				desc = "DDD: Aggregates",
				mode = "n",
			},
			{
				"<leader>zcdE",
				"<cmd>CopilotChatCreateDomainEvent<CR>",
				desc = "DDD: Domain Event",
				mode = "n",
			},
			{ "<leader>zcdN", "<cmd>CopilotChatAddNullabilityAnnotations<CR>", desc = "C#: Nullable", mode = "n" },
			{
				"<leader>zcdL",
				"<cmd>CopilotChatConvertToLINQ<CR>",
				desc = "C#: Convert to LINQ",
				mode = "n",
			},
			{
				"<leader>zcdO",
				"<cmd>CopilotChatOptimizeLINQ<CR>",
				desc = "C#: Optimize LINQ",
				mode = "n",
			},
			{
				"<leader>zcdM",
				"<cmd>CopilotChatGenerateMediatRHandler<CR>",
				desc = "C#: MediatR Handler",
				mode = "n",
			},
			{
				"<leader>zcdn",
				"<cmd>CopilotChatIntroduceEnum<CR>",
				desc = "C#: Introduce Enum",
				mode = "n",
			},
			{
				"<leader>zcdv",
				"<cmd>CopilotChatIntroduceValueObject<CR>",
				desc = "C#: Value Object",
				mode = "n",
			},
			{
				"<leader>zcdW",
				"<cmd>CopilotChatWriteXmlDocComments<CR>",
				desc = "C#: XML Docs",
				mode = "n",
			},
			{
				"<leader>zcdF",
				"<cmd>CopilotChatGenerateFluentValidation<CR>",
				desc = "C#: FluentValidation",
				mode = "n",
			},
		})

		-- ======================= JS / TS / VUE ONLY ==============================
		wk.add({
			{ "<leader>zje", group = "Explain/Review", mode = "n" },
			{ "<leader>zjf", group = "Refactor", mode = "n" },
			{ "<leader>zjt", group = "Tests", mode = "n" },
			{ "<leader>zjv", group = "Vue", mode = "n" },
			{ "<leader>zjm", group = "Misc", mode = "n" },

			-- Review
			{ "<leader>zjrs", "<cmd>CopilotChatJSSecurityReview<CR>", desc = "Security Review (JS)", mode = "n" },

			-- Refactor / JS-specific
			{
				"<leader>zjfa",
				"<cmd>CopilotChatJSConvertToAsyncAwait<CR>",
				desc = "Convert to async/await",
				mode = "n",
			},
			{ "<leader>zjft", "<cmd>CopilotChatJSAddTypesTS<CR>", desc = "Add TS types", mode = "n" },
			{ "<leader>zjfj", "<cmd>CopilotChatJSAddJSDoc<CR>", desc = "Add JSDoc/TSDoc", mode = "n" },
			{ "<leader>zjfz", "<cmd>CopilotChatJSGenerateZodSchema<CR>", desc = "Generate Zod schema", mode = "n" },
			{
				"<leader>zjfc",
				"<cmd>CopilotChatJSConvertCJS2ESM<CR>",
				desc = "Convert CJS → ESM",
				mode = "n",
			},
			{ "<leader>zjfo", "<cmd>CopilotChatJSTreeShakeOptimize<CR>", desc = "Optimize Tree-shaking", mode = "n" },

			-- Tests
			{ "<leader>zjtu", "<cmd>CopilotChatJSAddVitestTests<CR>", desc = "Vitest Unit Tests", mode = "n" },
			{ "<leader>zjti", "<cmd>CopilotChatJSAddPlaywrightTest<CR>", desc = "Playwright e2e Test", mode = "n" },

			-- Vue
			{
				"<leader>zjvr",
				"<cmd>CopilotChatVueExplainReactivity<CR>",
				desc = "Vue: Explain Reactivity",
				mode = "n",
			},
			{
				"<leader>zjvx",
				"<cmd>CopilotChatVueExtractComponent<CR>",
				desc = "Vue: Extract Component",
				mode = "n",
			},
			{
				"<leader>zjvc",
				"<cmd>CopilotChatVueRefactorToComposable<CR>",
				desc = "Vue: To Composable",
				mode = "n",
			},
			-- { "<leader>zjvp", "<cmd>CopilotChatVueCreatePiniaStore<CR>", desc = "Vue: Pinia Store",      mode = "n" },

			-- Misc (JS side can still use common, but keeping a couple handy)
			{ "<leader>zjmr", "<cmd>CopilotChatRename<CR>", desc = "Rename", mode = "n" },
			{
				"<leader>zjmG",
				"<cmd>CopilotChatGenerateCommitConventional<CR>",
				desc = "Conventional Commit",
				mode = "n",
			},
		})
		---------------------------------------------------------------------------
		-- VISUAL MODE GROUPS
		---------------------------------------------------------------------------
		wk.add({
			{ "<leader>z", group = "CopilotChat", mode = "v" },
			{ "<leader>zC", group = "Common", mode = "v" }, -- NEW: Common
			{ "<leader>zc", group = "C#/.NET", mode = "v" },
			{ "<leader>zj", group = "JS/TS/Vue", mode = "v" },

			-- Common selections
			{ "<leader>zCmr", "<cmd>CopilotChatRename<CR>", desc = "Rename (Sel.)", mode = "v" },
			{ "<leader>zCmC", "<cmd>CopilotChatMakeComponent<CR>", desc = "Make Component (Sel.)", mode = "v" },

			-- Common refactors (visual)
			{
				"<leader>zCfr",
				"<cmd>CopilotChatRefactorForReadability<CR>",
				desc = "Refactor: Readability",
				mode = "v",
			},
			{
				"<leader>zCfx",
				"<cmd>CopilotChatExtractFunction<CR>",
				desc = "Extract Function",
				mode = "v",
			},
			{
				"<leader>zCfi",
				"<cmd>CopilotChatExtractInterface<CR>",
				desc = "Extract Interface",
				mode = "v",
			},
			{
				"<leader>zCfg",
				"<cmd>CopilotChatAddGuardClauses<CR>",
				desc = "Add Guard Clauses",
				mode = "v",
			},
			{
				"<leader>zCfe",
				"<cmd>CopilotChatAddErrorHandling<CR>",
				desc = "Add Error Handling",
				mode = "v",
			},

			-- C# visual (DDD pieces generally act on any text too)
			{ "<leader>zcdA", "<cmd>CopilotChatDDDIdentifyAggregates<CR>", desc = "DDD: Aggregates", mode = "v" },
			{ "<leader>zcdE", "<cmd>CopilotChatCreateDomainEvent<CR>", desc = "DDD: Domain Event", mode = "v" },

			-- JS/TS/Vue visual
			{
				"<leader>zjfa",
				"<cmd>CopilotChatJSConvertToAsyncAwait<CR>",
				desc = "Convert to async/await",
				mode = "v",
			},
			{
				"<leader>zjft",
				"<cmd>CopilotChatJSAddTypesTS<CR>",
				desc = "Add TS types",
				mode = "v",
			},
			{
				"<leader>zjfj",
				"<cmd>CopilotChatJSAddJSDoc<CR>",
				desc = "Add JSDoc/TSDoc",
				mode = "v",
			},
			{
				"<leader>zjfz",
				"<cmd>CopilotChatJSGenerateZodSchema<CR>",
				desc = "Generate Zod schema",
				mode = "v",
			},
			{
				"<leader>zjfc",
				"<cmd>CopilotChatJSConvertCJS2ESM<CR>",
				desc = "Convert CJS → ESM",
				mode = "v",
			},
			{
				"<leader>zjvx",
				"<cmd>CopilotChatVueExtractComponent<CR>",
				desc = "Vue: Extract Component",
				mode = "v",
			},
			{
				"<leader>zjvc",
				"<cmd>CopilotChatVueRefactorToComposable<CR>",
				desc = "Vue: To Composable",
				mode = "v",
			},
		})
	end,
}
